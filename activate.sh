#!/bin/bash

# This script helps activate nix-darwin in the current shell
# Run this if darwin-rebuild is not found after installation
# todo: needs to check
if [ -f /etc/static/bashrc ]; then
    source /etc/static/bashrc
fi

if [ -f /etc/static/zshrc ]; then
    source /etc/static/zshrc
fi

# Add nix-darwin to PATH
export PATH="/run/current-system/sw/bin:$PATH"

echo "nix-darwin activated in current shell!"
echo "You can now use 'darwin-rebuild' command"