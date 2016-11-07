#!/usr/bin/python
import argparse
import sys
import os

__version__ = "0.1-dev"

def main():
    parser = argparse.ArgumentParser(description='xml2c.py v%s - XML to C header Utility' % __version__, prog='xml2c')
    parser.add_argument(
        '--input', '-i',
        help='Input XML file')

    parser.add_argument(
        '--output', '-o',
        help='Output header c file name')
    parser.add_argument(
        '--name', '-n',
        help='Variable name')

    args = parser.parse_args()
    lines = [line.rstrip('\n') for line in open(args.input)]
    lines_len = [line.strip() for line in open(args.input)]
    strlen = len(''.join(lines_len))
    lines = [create_str(line) for line in lines]
    out = 'const char ' + args.name + '[] = \\\n' + '\\\n'.join(lines) + ';\r\n'

    out = out + 'int ' + args.name + '_len = ' + str(strlen) + ';\n'


    with open(args.output, 'w') as wfile:
        wfile.write(out)

    print('Created {} from {} done'.format(args.output, args.input))

def create_str(line):
    space = ' ' * line.count(' ')
    return space + '"' + line.strip().replace('"', '\\\"') + '"'

if __name__ == '__main__':
    try:
        main()
    except ValueError as e:
        print '\nA fatal error occurred: %s' % e
        sys.exit(2)
