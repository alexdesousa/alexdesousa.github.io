# The Broken Link Blog

> Broken or dead link, a link that, having suffered link rot, points to a
> webpage or server that is no longer available on the World Wide Web.

Maintaining a blog should be simple: writing some content, adding some images,
save the changes, and publish. Services like [Medium](https://medium.com) or
[DEV Community](https://dev.to) already solve this problem, then... Why
reinventing the wheel?

There's nothing wrong on using Medium or DEV Community for posting articles.
Their business is to host blogs for free and then, directly or indirectly,
monetize the contents others create. [Github](https://github.com) does exactly
the same, not with blogs, but with open-source code.

## Technologies

For this blog I use:

- _Github Pages_ for hosting it.
- _Jekyll_ for generating the static site.
- _TailwindCSS_ for the site styling.
- _Travis CI_ for building and deploying it.

## Why Github Pages?

Though Medium and DEV are specialized in hosting blogs and give you visibility,
I don't like their workflow for publishing articles. However, I do like the
workflow _Github Pages_ gives me:

- I can write a blog using the same tools I use for writing code: `vim`, `zsh`
  and `git`. I feel confortable and more creative in this cocoon I've created.
- By default, I would have a backup of all my articles in my computer. If
  somehow Github decides my ideas shouldn't be heard, then I would have the
  content I've created. Censorship it's easier when there's centralization.
- I can use [thebroken.link](https://thebroken.link) as domain name instead of
  [alexdesousa.github.com](https://alexdesousa.github.com) by
  [changing my domain's `A` and `CNAME` records](https://help.github.com/en/articles/using-a-custom-domain-with-github-pages)
- Automatically renews the[SSL certificate for my domain name](https://help.github.com/en/articles/securing-your-github-pages-site-with-https).

The requirements are:

- The repository must be named as `<username>.github.io`.
- The static site must be in the `master` branch.
- Tick the checkbox for enforcing HTTPS in the project's settings.

## Why Jekyll?

I don't love Ruby. I also don't hate it. However, though Jekyll is written in
Ruby, it's easy enough to use without any previous Ruby knowledge. I just
followed the [step-by-step tutorial](https://jekyllrb.com/docs/step-by-step/01-setup/)
they had in the project's page.

The theme was inspired by [Ghostwind](https://github.com/tailwindtoolbox/Ghostwind)
and uses _TailwindCSS_ for the styling.

I tried to keep the JS to the minimum in order to make the page as light as
possible.

My `Gemfile` looks like the following:

```ruby
source "https://rubygems.org"

gem "jekyll"
gem "html-proofer"

group :jekyll_plugins do
  gem "redcarpet"
  gem "jekyll-last-modified-at"
  gem "jekyll-minimagick"
  gem "jekyll-roman"
end
```

## Why Travis CI?

_Travis CI_ is actually the technology that glues both _Github Pages_ and
_Jekyll_ together. Every time I push changes to the `blog` branch, it
automatically builds and deploys the site to the `master` branch. My
`.travis.yml` file is as follows:

```yaml
language: ruby
rvm:
  - 2.6
before_install:
  - nvm install 17.3.0
install:
  - gem install bundler
  - bundle install
  - npm install
  - NODE_ENV=production npm run build
script:
  - bundle exec jekyll build
  - bundle exec htmlproofer ./_site --disable-external

deploy:
  provider: pages
  skip_cleanup: true
  github_token: $GITHUB_TOKEN
  keep_history: true
  on:
    branch: blog
  local-dir: _site
  target-branch: master
```

> **Note**: The `$GITHUB_TOKEN` is an access token that allows _Travis CI_ to
> commit the contents of `_site/` to the `target-branch`. You can generate your
> own token [here](https://github.com/settings/tokens).

## Building the Project

[This project](https://github.com/alexdesousa/alexdesousa.github.io) depends on
[asdf-vm](https://github.com/asdf-vm/asdf) and its ruby plugin e.g:

```bash
$ asdf install           # Installs Ruby.
$ gem install bundler    # Installs bundler.
$ bundle install         # Installs Jekyll dependencies.
$ npm install            # Installs CSS dependencies.
```

Before you do the previous, make sure you installed the following using `asdf`:

- NodeJS 17.3.0
- Ruby 2.6.9

## Running the Server

Jekyll comes with a testing server that runs in
[localhost:4000](http://localhost:4000/en/) e.g:

```bash
$ ./runblog.sh
```
