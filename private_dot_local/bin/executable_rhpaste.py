#!/usr/bin/env python

# Courtesy of https://github.com/jlebon/files/blob/master/bin/rhpaste

import sys
import argparse
import requests


def parse_args():
    parser = argparse.ArgumentParser(
        description="Upload file to the Red Hat pastebin")
    parser.add_argument("-l", "--lang", default='text',
                        help="language to use for syntax highlighting")
    parser.add_argument("-n", "--name", default='',
                        help="name of uploader")
    parser.add_argument("-e", "--expiry", default='d',
                        help="time before paste is removed",
                        choices=["day", "month", "forever"])
    parser.add_argument("-f", "--file", default='-',
                        help="file to upload (use '-' for stdin)")
    parser.add_argument("-v", "--verbose", action="store_true")
    return parser.parse_args()


def read_data(filename):
    if filename == '-':
        return sys.stdin.read()
    with open(filename) as f:
        return f.read()


def upload_data(data, lang, expiry, name):
    payload = {'paste': 'Send',
               'expiry': expiry[0],
               'format': lang,
               'poster': name,
               'code2': data}
    r = requests.post("http://pastebin.test.redhat.com/pastebin.php",
                      data=payload, allow_redirects=False)
    if r.status_code != requests.codes.ok:
        r.raise_for_status()
    return r.headers['location']


def main():
    args = parse_args()
    data = read_data(args.file)
    url = upload_data(data, args.lang, args.expiry, args.name)
    print(url)

if __name__ == "__main__":
    main()
