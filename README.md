# TesTLS
Pick your ciphers and build a test TLS endpoint for testing against your applications in less than 5 minutes!

## About
Tell TesTLS what TLS versions and associated ciphers you want to enable and it will generate a script that configures a CentOS 8 server exactly as you specify. It autoconfigures Apache, grabs certificates from LetsEncrypt and applies your TLS settings.

TesTLS is primarily intended for organisations who are either deprecating old versions of TLS and want to test their applications against a TLS1.2/1.3 server to see if they can negotiate a TLS session successfully, or are otherwise revising their TLS/cipher policy.

It could also be used for improving your existing cipher policy to increase security in a situation where you may not otherwise be able to yet disable TLS 1.1 and lower.

To use this tool, visit: https://einichi.github.io/TesTLS

## Project outline

- testls.sh - Base script that performs the installation and configuration of Apache to serve as a TLS testing endpoint with specific TLS protocols and associated ciphers
- test-testls.py - Makes a copy of the base script, filling in vars and commenting out difficult deps for use in CI testing
- create-script-include.py - Simply escapes the angle brackets in the HTML elements in the testls.sh script so they can be displayed properly on a webpage, then placing it into the _includes dir for the jekyll site
- ciphers2json.py - Grabs all available ciphers for each TLS protocol and serialises them into a JSON file
- site/index.html - Allows people to pick and choose their ciphers and generates a personalised installation script for them. Uses bootstrap, jquery, prism and some custom JS.
- site/terms.html - Basic terms of use, including Let's Encrypt subscriber agreement info
- site/assets/js/tlstest-fill-script.js - Hooks page events to update variables in the script and builds protocol and cipher strings based on selections made
