#!/bin/sh
cd secrets || exit 1

if [ -z "$1" ]; then
    agenix -r
else
    EDITOR=nano agenix -e "$1.age"
fi
