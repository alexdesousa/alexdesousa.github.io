#!/usr/bin/env bash

./install_theme.sh
pelican content -o output -s publishconf.py
cp CNAME output/
ghp-import -b master output
rm -rf __pycache__ output

