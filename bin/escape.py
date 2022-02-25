#!/usr/bin/env python3

import html
import cgi
import sys

while True:
    line = sys.stdin.readline()
    if line:
        print(html.escape(line).encode('ascii', 'xmlcharrefreplace').decode())
    else:
        break
