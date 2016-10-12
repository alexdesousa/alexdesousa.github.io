#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

# General config
HOSTNAME = 'http://192.168.1.134:8000'
AUTHOR = 'Alex de Sousa'
SITEURL = HOSTNAME
SITENAME = 'The Broken Link'
SITESUBTITLE = 'Alex de Sousa'
SITEDESCRIPTION = 'Public Access to my Mind'
SITELOGO = '//s.gravatar.com/avatar/a76a95afc057ad48adb144cd825bc3a2?s=200'
FAVICON = 'http://thebroken.link/favicon.ico'
BROWSER_COLOR = '#333333'
PYGMENTS_STYLE = 'github'
THEME = '../pelican-themes/Flex'
TIMEZONE = 'Europe/Madrid'
DEFAULT_LANG = 'en'
OG_LOCALE = 'en_US'
DEFAULT_PAGINATION = 5
PATH = 'content'
DEFAULT_DATE = 'fs'

# Menu
MAIN_MENU = True
MENUITEMS = (
    ('CV', '/cv.html'),
    ('Blog', '/blog/tech/')
)

# Static paths
STATIC_PATHS = [
    'extra'
]

EXTRA_PATH_METADATA = {
    'extra/favicon.ico': {'path': 'favicon.ico'},
    'extra/CNAME': {'path': 'CNAME'}
}

# Feed
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Social widget
SO = 'http://stackoverflow.com/users/4776680/alexander-de-sousa'
SOCIAL = (
    ('github', 'https://github.com/alexdesousa'),
    ('linkedin', 'https://es.linkedin.com/in/ajdesousa'),
    ('twitter', 'https://twitter.com/thebroken_link'),
    ('stack-overflow', SO)
)

# Blogroll
LINKS = (
        ('Blog', 'http://thebroken.link/blog/'),
)

# Pages
PAGE_PATHS = ['pages']
PAGE_URL = '{slug}/'
PAGE_SAVE_AS = '{slug}/index.html'

# Blog
CATEGORY_SAVE_AS = '/blog/{slug}/index.html'
CATEGORY_URL = '/blog/{slug}/'
INDEX_SAVE_AS = '/blog/index.html'

PAGINATION_PATTERNS = (
    (1, '{base_name}/', '{base_name}/index.html'),
    (2, '{base_name}/page/{number}/', '{base_name}/page/{number}/index.html'),
)

# Comments
DISQUS_SITENAME = 'thebroken-link'

# Google Analytics
GOOGLE_ANALYTICS = 'UA-85600451-1'

# Twitter
TWITTER_USERNAME = 'thebroken_link'

DISPLAY_PAGES_ON_MENU = False
DISPLAY_CATEGORIES_ON_MENU = False
USE_FOLDER_AS_CATEGORY = False
