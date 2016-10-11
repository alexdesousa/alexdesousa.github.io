#!/usr/bin/env bash

git clone https://github.com/getpelican/pelican-themes.git ../pelican-themes
cd  ../pelican-themes
git submodule update --init -- Flex/
