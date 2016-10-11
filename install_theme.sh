#!/usr/bin/env bash

DIRECTORY=../pelican-themes

if [ ! -d "$DIRECTORY" ]; then
    git clone https://github.com/getpelican/pelican-themes.git $DIRECTORY
fi
cd  ../pelican-themes
git pull
git submodule update --init -- Flex/
