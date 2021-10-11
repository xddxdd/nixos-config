#!/bin/sh
cd secrets || exit 1

if [ -z "$1" ]; then
    nix run github:ryantm/agenix -- -r
else
    EDITOR=nano nix run github:ryantm/agenix -- -e "$1.age"
fi
