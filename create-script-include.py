#!/usr/bin/env python3

scriptname='build-a-test-tls-endpoint.sh'
outputfile='site/_includes/script.sh'

with open(outputfile, 'w') as output:
    for line in open(scriptname):
        # Escape tag opening
        output.write(line.replace('<', '&lt;'))