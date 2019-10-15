#!/usr/bin/env python3

scriptname='testls.sh'
outputfile='site/_includes/script.sh'

with open(outputfile, 'w') as output:
    for line in open(scriptname):
        # Escape tag opening
        output.write(line.replace('<', '&lt;'))
