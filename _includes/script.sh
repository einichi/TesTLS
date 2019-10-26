#!/bin/bash

# testls.sh
# Last updated 2019-10-14
# By Ricky Burgin &lt;ricky@burg.in>
# Licensed under the GNU General Public License v3.0: https://www.gnu.org/licenses/gpl-3.0.en.html
# Code repository: https://github.com/einichi/testls

# !!! YOU MUST SET THE VARIABLES BELOW BEFORE EXECUTING THIS SCRIPT !!!
# !!! SCRIPT MUST ALSO BE EXECUTED AS ROOT USER !!!

# Exit immediately on any failure
set -e

# HOST - Enter the hostname you want to use for testing.
# This must be a valid, resolvable hostname that points to the
# server you run this script on.
HOST=""
# EMAIL - Used for registering with LetsEncrypt just in case you
# need to recover certs for your hostname
EMAIL=""
# AGREE - Set this to "true" if you have read, understood and agree with the Terms of Use for TesTLS.
# The Terms are available in the git repository linked at the top of this script or on the TesTLS website.
# http://einichi.github.io/testls/terms.html
# Do not set this to true if you have not read or otherwise do not agree with these terms.
AGREE="false"
# PROTOCOLS - Specify your TLS protocols here as per Apache documentation
# https://httpd.apache.org/docs/2.4/mod/mod_ssl.html#sslprotocol
PROTOCOLS=""
# CIPHERS - Specify the cipher suite here using the standard OpenSSL format
# Apache docs has useful explanation: https://httpd.apache.org/docs/2.4/mod/mod_ssl.html#sslciphersuite
CIPHERS=""
# HONOR - Have the server force the order of cipher preference onto the connecting clients.
# Set to no by default, as the autogen script does not generate ciphers with any kind of useful order.
# Set this to 'on' if you want to re-order the ciphers above and have them used in that order.
# https://httpd.apache.org/docs/2.4/mod/mod_ssl.html#sslhonorcipherorder
HONOR="off"

# Targeted to CentOS 8. Fedora might also work, but is not tested.
# Uses LetsEncrypt and so is limited to testing ciphers that match the
# certificate type that LetsEncrypt is issuing at time of execution.
# This is currently RSA.

# Check if root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   echo "If this script wasn't auto-generated for you,\n
make sure you also check the configuration variables\n
inside the script near the top." 
   exit 1
fi
# Check if agreed to terms
# Checking string instead of boolean due to peculiar issue with Prism syntax highlighting bash plugin not recognising booleans
if ! [[ $AGREE == "true" ]] ; then
   echo "You must read and agree to the terms here: http://einichi.github.io/testls/terms.html\n
before executing this script. Set the AGREE var to true if you agree. You can also find the terms\n
in the Git repo under site/terms.html."
   exit 2
fi
# Check if config variables are set
if [[ -z $HOST ]] ; then
    echo "Hostname variable not set."
    exit 3
fi
if [[ -z $EMAIL ]] ; then
    echo "Email variable is not set."
    exit 4
fi
if [[ -z $PROTOCOLS ]] ; then
    echo "Protocols variable is not set."
    exit 5
fi
if [[ -z $CIPHERS ]] ; then
    echo "Ciphers variable is not set."
    exit 6
fi
if [[ -z $HONOR ]] ; then
    echo "Honor variable is not set."
    exit 7
fi
# Update system packages
dnf update -y
# Set system hostname to user-provided hostname
hostnamectl set-hostname $HOST
# Allow port 80 and 443 through
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=443/tcp --permanent
firewall-cmd --reload
# Install necessary system packages via dnf
# Packages other than httpd and mod_ssl are required for using certbot
# for installing LetsEncrypt certificate
dnf install httpd mod_ssl gcc python3-virtualenv python3-devel \
redhat-rpm-config augeas-libs libffi-devel openssl-devel -y
# Install certbot
wget https://dl.eff.org/certbot-auto -O /usr/local/bin/certbot-auto
chmod 0755 /usr/local/bin/certbot-auto
# Create vhost dir
mkdir -p /var/www/$HOST/html
# Generate index page for vhost
cat > /var/www/$HOST/html/index.html &lt;&lt;EOF
&lt;html>
	&lt;head>
		&lt;title>TLS Test - $HOST&lt;/title>
	&lt;/head>
	&lt;body>
		&lt;h1>Success&lt;/h1>
		&lt;p>You successfully connected to the $HOST TLS test server.&lt;/p>
		&lt;p>It was installed with the below parameters:&lt;/p>
        &lt;p>Protocols enabled: $PROTOCOLS&lt;p>
        &lt;p>Cipher Suite: $CIPHERS&lt;/p>
	&lt;/body>
&lt;/html>
EOF
# Create non-TLS vhost config - this allows LetsEncrypt to verify we operate this domain
cat > /etc/httpd/conf.d/$HOST.conf &lt;&lt;EOF
&lt;VirtualHost *:80>
        ServerName $HOST
        DocumentRoot /var/www/$HOST/html
&lt;/VirtualHost>
EOF
# Add Include for vhost config to Apache
# Seems that all of conf.d is IncludedOptional'd by default
# but Apache should fail if it can't find our vhost config
# so we add an Include anyway. Also useful if this behaviour
# changes in the future.
echo "Include conf.d/$HOST.conf" >> /etc/httpd/conf/httpd.conf
# Enable Apache to autostart, and then start it
systemctl enable httpd
systemctl start httpd
# Run CertBot and have it generate our certs and install them for us
/usr/local/bin/certbot-auto certonly --apache --non-interactive --agree-tos -m $EMAIL --domains $HOST
# Have crontab run the CertBot renewal script occasionally, with LE's recommendations
echo "0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && /usr/local/bin/certbot-auto renew" | tee -a /etc/crontab > /dev/null
# Create TLS vhost config
cat > /etc/httpd/conf.d/$HOST.conf &lt;&lt;EOF
&lt;IfModule mod_ssl.c>
    &lt;VirtualHost *:443>
        ServerName $HOST
        DocumentRoot /var/www/$HOST/html
        SSLCertificateFile /etc/letsencrypt/live/$HOST/fullchain.pem
        SSLCertificateKeyFile /etc/letsencrypt/live/$HOST/privkey.pem
        SSLEngine on
        SSLProtocol $PROTOCOLS
        SSLCipherSuite $CIPHERS
        SSLHonorCipherOrder $HONOR
    &lt;/VirtualHost>
&lt;/IfModule>
EOF
# Overwrite ssl.conf with minimal config
cat > /etc/httpd/conf.d/ssl.conf &lt;&lt;EOF
Listen 443 https
SSLSessionCache shmcb:/run/httpd/sslcache(512000)
SSLSessionCacheTimeout 300
EOF
# Restart Apache to apply new config
systemctl restart httpd
# Restart system
# Just in case a new kernel version was installed
echo "Rebooting the system."
echo "After it comes back up, your TLS endpoint will be available at: https://$HOST/"
echo "Press CTRL+C now if you do not want to reboot."
secs=15
while [ $secs -gt 0 ]; do
   echo -ne "Rebooting in $secs\033[0K\r"
   sleep 1
   : $((secs--))
done
reboot
