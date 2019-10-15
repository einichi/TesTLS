#!/usr/bin/env python3
# Test your TesTLS before you test your TLS! :s

scriptname = 'testls.sh'
outputfile = 'no-le-or-systemd-testls.sh'

with open(outputfile, 'w') as output:
    blockcomment = False
    for line in open(scriptname):
        if "# Create TLS vhost config" in line:
            output.write(line)
            blockcomment = True
        elif blockcomment == True:
            output.write("# " + line)
            if line == "EOF\n":
                blockcomment = False
        elif "HOST=" in line:
            output.write("HOST=\"test.hostname\"\n")
        elif "EMAIL=" in line:
            output.write("EMAIL=\"test@email.address\"\n")
        elif "AGREE=" in line:
            output.write("AGREE=\"true\"\n")
        elif "PROTOCOLS=" in line:
            output.write("PROTOCOLS=\"+TLSv1.3 +TLSv1.2 +TLSv1.1 +TLSv1\"\n")
        elif "CIPHERS=" in line:
            output.write("CIPHERS=\"TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ARIA256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA\"\n")
        elif "/usr/local/bin/certbot-auto certonly" in line:
            output.write("# " + line)
        elif "dnf update" in line:
            output.write("dnf update -y --exclude=systemd*\n")
        elif "firewall-cmd" in line:
            output.write("# " + line)
        elif "systemctl" in line:
            output.write("# " + line)
        elif "reboot" in line:
            output.write("# " + line)
        else:
            output.write(line)
