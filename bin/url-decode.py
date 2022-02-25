#!/usr/bin/env python3

import html
import sys

with sys.stdin:
    for line in sys.stdin.readlines():
        sys.stdout.write(html.unescape(line))
