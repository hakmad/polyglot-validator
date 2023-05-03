#!/usr/bin/env python3

"""Polyglot validator program.

Provides functions to validate polyglots against file format specifications.
"""

import argparse


from formats import *


available_formats = {
        "gif": gif.Gif,
        "jpeg": jpeg.Jpeg,
        "png": png.Png,
        "zip": zip.Zip,
}


def main():
    """Main CLI program."""
    # Setup argument parser.
    parser = argparse.ArgumentParser(
            description="A CLI tool for validating polyglots")

    # Setup options for argument parser.
    parser.add_argument("-i", "--input-file", type=argparse.FileType("rb"),
                        required=True)
    parser.add_argument("-f", "--format", choices=available_formats.keys(),
                        required=True)
    parser.add_argument("-v", "--verbose", action="store_true", dest="verbose")

    args = parser.parse_args()

    try:
        parsed_file = available_formats[args.format].from_bytes(args.input_file.read())

        print("{} is a valid {} file".format(args.input_file.name, args.format))
    except Exception as e:
        print("{} is not a valid {} file".format(args.input_file.name, args.format))
        
        if args.verbose:
            print(e)


if __name__ == "__main__":
    main()
