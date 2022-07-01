#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# TODO collect formatted device tuples for alternate output formats

import json
import re
import sys
from subprocess import Popen, PIPE

vendor_id_re = '^0x(?P<vendor_id>[0-9a-f]{4})(?: *\((?P<manufacturer>[^)]+)\))*$'
location_id_re = '^0x[0-9a-f]{2}(?P<bus_num>[0-9a-f]{2})[0-9a-f]+(?: +/ (?P<device_num>\d+))?$'


def formatHostController(device):
    print('TODO: format host controller')
    # {usb_bus_number, _name, pci_vendor, pci_device}
    pass

def parseVendorID(vendor_id_str):
    vendor_id = '0000'
    manufacturer = ''
    if vendor_id_str:
        if vendor_id_str == 'apple_vendor_id':
            vendor_id = '0000'
            manufacturer = 'Apple Inc.'
        else:
            match = re.search(vendor_id_re, vendor_id_str)
            if match:
                vendor_id = match.groupdict().get('vendor_id')
                manufacturer = match.groupdict().get('manufacturer')
            else:
                print(f"Couldn't parse vendor_id: {vendor_id_str}", file=sys.stderr)
    return (vendor_id, manufacturer)

def parseLocationID(location_id):
    bus_num = 0 
    device_num = 0
    if location_id:
        match = re.search(location_id_re, location_id)
        if match:
            bus_num = int(match.groupdict().get('bus_num'), 16)
            device_num = match.groupdict().get('device_num')
            if device_num:
                device_num = int(device_num)
            else:
                device_num = 0
        else:
            print(f'ERROR parsing location_id: {location_id}', file=sys.stderr)
    return (bus_num, device_num)

def parseProductID(product_id_str):
    product_id = '0000'
    if product_id_str:
        if product_id_str.startswith('0x'):
            try:
                product_id = product_id_str[2:]
            except IndexError:
                print(f'ERROR: non-hex product_id, {product_id_str}', file=sys.stderr)
    return product_id

def formatDevice(device):
    name = device.get('_name').rstrip()
    (bus_num, device_num) = parseLocationID(device.get('location_id')) 
    (vendor_id, manufacturer) = parseVendorID(device.get('vendor_id'))
    product_id = parseProductID(device.get('product_id'))
    serial_num = device.get('serial_num', '')

    try:
        print(f'Bus {bus_num:03} Device {device_num:03}: ID {vendor_id}:{product_id} {manufacturer} {name}  Serial: {serial_num}')
    except ValueError as e:
        print(f'ERROR: failed to parse device: {e}', file=sys.stderr)

def transform(device):
    if isinstance(device, object) and '_name' in device:
        if 'host_controller' in device:
            formatHostController(device)
        else:
            formatDevice(device)
        if '_items' in device:
            list(map(transform, device.get('_items')))
    elif isinstance(device, list):
        list(map(transform, device))
    else:
        print('unknown')

if __name__ == '__main__':
    with Popen(['system_profiler', '-json', 'SPUSBDataType'], stdout=PIPE) as proc:
        jsonData = proc.stdout.read()
        usbData = json.loads(jsonData)
        transform(usbData.get('SPUSBDataType'))

