#!/usr/bin/env bash

./install_theme.sh
pelican content -o output -s publishconf.py
ghp-import -b master output
rm -rf __pycache__ output

