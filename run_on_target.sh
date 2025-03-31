#!/bin/sh

# This script is intended to be run the program on the target device
# It uses gdb and openocd to load the program onto the target device
# The ENV variables TARGET_HOST must be set to a resolvable hostname:port
# The script just takes one argument, the elf file to run

# Check if the target host is set
if [ -z "$TARGET_HOST" ]; then
    echo 'TARGET_HOST is not set! Type "export TARGET_HOST=yourhost:3333" to setup a connection to openocd.' >&2
    exit 1
fi

# Check if the elf file is set
if [ -z "$1" ]; then
    echo "No elf file specified" >&2
    exit 1
fi

# Check if the elf file exists
if [ ! -f "$1" ]; then
    echo "File \"$1\" does not exist" >&2
    exit 1
fi

# Check if the elf file is an elf file
if ! file "$1" | grep -q "ELF"; then
    echo "File \"$1\" is not an elf file" >&2
    exit 1
fi

# start gdb
gdb-multiarch \
    -ex "set pagination off" \
    -ex "target remote $TARGET_HOST" \
    -ex "monitor reset halt" \
    -ex "load" \
    -ex "monitor reset init" \
    -ex "monitor resume" \
    -ex "detach" \
    -ex "quit" \
    "$1" >/dev/null