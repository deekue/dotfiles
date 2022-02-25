#!/usr/bin/env python3

import cgi
import sys
import urllib

with sys.stdin:
    for line in sys.stdin.readlines():
        sys.stdout.write(urllib.parse.quote(line))
