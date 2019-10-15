#!/usr/bin/env python3

# Re-using some old code and regex to generate a JSON output of
# ciphers supported by TLS version / OpenSSL version
# for use in the TLS endpoint installerscript generator.
# Yes I realise this is far from the best way to do this.
# Prototyping phase!

import subprocess, re, json

def get_ciphers(tlsversion):
    if tlsversion=="13":
        ciphers=subprocess.run(['openssl', 'ciphers', '-s', '-tls1_3', '-V', 'ALL'], stdout=subprocess.PIPE).stdout.decode('utf-8') 
    elif tlsversion=="12":
        ciphers=subprocess.run(['openssl', 'ciphers', '-s', '-tls1_2', '-V', 'ALL'], stdout=subprocess.PIPE).stdout.decode('utf-8')
    elif tlsversion=="11":
        ciphers=subprocess.run(['openssl', 'ciphers', '-s', '-tls1_1', '-V', 'ALL'], stdout=subprocess.PIPE).stdout.decode('utf-8')
    elif tlsversion=="10":
        ciphers=subprocess.run(['openssl', 'ciphers', '-s', '-tls1', '-V', 'ALL'], stdout=subprocess.PIPE).stdout.decode('utf-8')
    regex = re.findall("0x([0-9A-Z]{2}),0x([0-9A-Z]{2})(\s-\s)([\w\-_]+).*", ciphers)
    cipherlist = ()
    for cipher in regex:
        cipherlist=cipherlist+((cipher[3]),)
    return cipherlist

#tls = []
#tls.append({"openssl_version": subprocess.run(['openssl', 'version'], stdout=subprocess.PIPE).stdout.decode('utf-8').replace('\n', '')})
#tls.append({"tls1.3ciphers": (get_ciphers("13"))})
#tls.append({"tls1.2ciphers": (get_ciphers("12"))})
#tls.append({"tls1.1ciphers": (get_ciphers("11"))})
#tls.append({"tls1.0ciphers": (get_ciphers("10"))})

tls = {'openssl_version': subprocess.run(['openssl', 'version'], stdout=subprocess.PIPE).stdout.decode('utf-8').replace('\n', '')}
tls['tls1_3ciphers'] = get_ciphers("13")
tls['tls1_2ciphers'] = get_ciphers("12")
tls['tls1_1ciphers'] = get_ciphers("11")
tls['tls1_0ciphers'] = get_ciphers("10")
with open('./site/_data/ciphers.json', 'w', encoding='utf-8') as f:
    json.dump(tls, f, ensure_ascii=False, indent=4)
