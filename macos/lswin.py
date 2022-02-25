#!/usr/bin/env python

import argparse
import json
import Quartz

def getQuartzWindowList():
    #wl = Quartz.CGWindowListCopyWindowInfo( Quartz.kCGWindowListOptionOnScreenOnly | Quartz.kCGWindowListExcludeDesktopElements, Quartz.kCGNullWindowID)
    wl = Quartz.CGWindowListCopyWindowInfo( Quartz.kCGWindowListOptionAll, Quartz.kCGNullWindowID)

    wl = sorted(wl, key=lambda k: k.valueForKey_('kCGWindowOwnerPID'))
    return wl

def printTable(wl):
    print('PID'.rjust(7) + ' ' + 'WinID'.rjust(5) + '  ' + 'x,y,w,h'.ljust(21) + ' ' + '\t[Title] SubTitle')
    print('-'.rjust(7,'-') + ' ' + '-'.rjust(5,'-') + '  ' + '-'.ljust(21,'-') + ' ' + '\t-------------------------------------------')

    for v in wl:
        try:
            print ( \
                str(v.valueForKey_('kCGWindowOwnerPID') or '?').rjust(7) + \
                ' ' + str(v.valueForKey_('kCGWindowNumber') or '?').rjust(5) + \
                ' {' + ('' if v.valueForKey_('kCGWindowBounds') is None else \
                    ( \
                        str(int(v.valueForKey_('kCGWindowBounds').valueForKey_('X')))     + ',' + \
                        str(int(v.valueForKey_('kCGWindowBounds').valueForKey_('Y')))     + ',' + \
                        str(int(v.valueForKey_('kCGWindowBounds').valueForKey_('Width'))) + ',' + \
                        str(int(v.valueForKey_('kCGWindowBounds').valueForKey_('Height'))) \
                    ) \
                    ).ljust(21) + \
                '}' + \
                '\t[' + ((v.valueForKey_('kCGWindowOwnerName') or '') + ']') + \
                ('' if v.valueForKey_('kCGWindowName') is None else (' ' + v.valueForKey_('kCGWindowName') or '')) \
            )#.encode('utf8')
        except Exception as e:
            print(e)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-j',
                        '--json',
                        help='output json',
                        action='store_true',
                        default=False)
    args = parser.parse_args()

    wl = getQuartzWindowList()

    if args.json:
        print(wl)
    else:
        printTable(wl)
