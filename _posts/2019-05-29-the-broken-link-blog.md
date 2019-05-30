---
layout: article
title: The Broken Link Blog
description: Create a blog using Jekyll and GitHub Pages
author: Alex de Sousa
---

> Broken or dead link, a link that, having suffered link rot, points to a
> webpage or server that is no longer available on the World Wide Web.

Maintaining a blog should be simple: writing some content, adding some images,
save the changes and publish it. Services like
[Medium](https://medium.com) or [DEV Community](https://dev.to) already solve
this problem, then... Why reinventing the wheel?

> _If a service is free, you're the product_

There's nothing wrong on using Medium or DEV Community for posting articles.
Their business is to host blogs for free and then, directly or indirectly,
monetize the contents others create. [Github](https://github.com) does exactly
the same.

Though Medium and DEV are specialized in hosting blogs and give you visibility,
I don't like their workflow for publishing articles. However, I do like the
workflow Github Pages gives me:

- I can write a blog using the same tools I use for writing code: `vim`, `zsh`
  and `git`. I feel confortable and more creative in this cocoon I've created.
- By default, I have a backup of all my articles in my computer. If somehow
  Github decides my ideas shouldn't be heard, then I would have the content
  I've created. Censorship it's easier when there's centralization (Go
  Bitcoin!).

> **Important**: For Github Pages you would need to create a new repository
> with the following name: `<your username>.github.io`.

## Why Jekyll?

I don't love Ruby. I also don't hate it. Though, my professional experience
does not include Ruby, Jekyll is written in Ruby. The following are the reasons
I chose Jekyll:

- Amazing documentation.
- Easy to use.
- Awesome plugins.
- No need of Ruby knowledge or, at least, not too much.

> **Note**: There's a great
> [step-by-step Jekyll tutorial](https://jekyllrb.com/docs/step-by-step/01-setup/)
> in their webpage. Everything said here only documents my experience following
> it plus some other useful tips.

## Installing Ruby

Like I said before, Jekyll is written in Ruby, so we need Ruby. There are
several methods for installing Ruby, but I really like
[asdf](https://github.com/asdf-vm/asdf) to install new languages in my machine
(I use it for Elixir and Erlang).

First, I installed the Ruby plugin and the latest version of the language for
the project:

```bash
$ asdf plugin-add ruby    # For installing the plugin for Ruby
$ asdf install ruby 2.6.3 # Installs the latest version for Ruby
$ asdf local ruby 2.6.3   # Sets the project's Ruby version in `tool-versions`
```

> **Note**: Ruby 2.6.3 is the latest stable version at the time of the writing.

Then, I installed `bundler` gem:

```bash
$ gem install bundler
```

Finally, having `bundler` installed, I can init a new Ruby project:

```bash
$ bundle init
```

## Installing Jekyll

This is a programming blog, so for me is very important to have great support
for beautiful code blocks. Personally, I really like this
[Monokai theme](https://raw.githubusercontent.com/jwarby/pygments-css/master/monokai.css)
that I picked up from
[jwarby Jekyll's pygments themes](http://jwarby.github.io/jekyll-pygments-themes/languages/javascript.html).

Having that in mind, let's install two gems:

- `jekyll`, of course.
- `redcarpet` for handling my markdown using pygments syntax highlight.

Then our `Gemfile` should look like the following:

```ruby
source "https://rubygems.org"

gem "jekyll"
gem "redcarpet"
```

and we can now install our dependencies:

```bash
$ bundle install
```

## Getting Started

Jekyll has a specific way of dealing with templates and assets. The following
is a general description of each file/folder:

- `_config.yml`: Jekyll configuration.
- `_layouts`: folder for HTML templates for every page.
- `_includes`: folder for reusable HTML templates. Things like navigation bars,
  reading time widgets, among others should be placed here.
- `_posts`: folder for the posts.
- `assets/{css,js,img}`: folders for static assets like images, and CSS and
  Javascript files.
- `index.html`: default entry point for your webpage.

## Our First Layout

When building our static site with Jekyll, every markdown file will be
converted to HTML. For that we would need a general layout for our page e.g
let's start with `_layouts/default.html`:

{% raw %}
```html
<!doctype html>
<html>
  <head>
    <title>{{ page.title }}</title>
  </head>
  <body>
    {{ content }}
  </body>
</html>
```
{% endraw %}

Now we could create a file called `index.md` with the following format:

{% raw %}
```markdown
---
layout: default
title: Hello World!
---

# Hello World!

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua.
```
{% endraw %}

If we now run our testing server:

```bash
$ bundle exec jekyll serve
```

and go to [localhost:4000](localhost:4000) in our browser we could see the
following HTML:

```html
<!doctype html>
<html>
  <head>
    <title>Hello World!</title>
  </head>
  <body>
    <h1>Hello World!</h1>
    <p>
      Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
      tempor incididunt ut labore et dolore magna aliqua.
    </p>
  </body>
</html>
```

## Using Redcarpet

If we want to use syntax highlight, we should configure `redcarpet` markdown
gem as follows:

```yaml
markdown: redcarpet
redcarpet:
  extensions: [
    "no_intra_emphasis",
    "fenced_code_blocks",
    "autolink",
    "strikethrough",
    "superscript"
  ]
```

and copy our pygments CSS file to `assets/css/pygments` e.g. `monokai.css` and
include it in our `assets/css/main.css`:

```css
@import url(pygments/monokai.css);

/* General Layout. */

pre {
  white-space: pre;
  overflow-x: auto;
}

code {
  color: #FFFFFF;
  background-color: #272822;
  padding: 2px 3px 2px 3px;
  border-radius: 3px;
  font-size: 15px;
}

/* ... more custom CSS ... */
```

Finally, we need to include `assets/css/main.css` in any of our templates e.g:
`_includes/head.html` for managing our `head` HTML tag:

{% raw %}
```html
<head>
  <title>{{ page.title }}</title>
  <link rel="stylesheet" href="{{ "/assets/css/main.css?version=20190529" | prepend: site.baseurl }}">
</head>
```
{% endraw %}

Now we can modify `_layouts/default.html` to include our
`_includes/head.html` and our CSS with it:

{% raw %}
```html
<!doctype html>
<html>
  {% include head.html %}
  <body>
    {{ content }}
  </body>
</html>
```
{% endraw %}

And we can now modify our `index.md` to add some code:

{% raw %}
```markdown
---
layout: default
title: Hello World!
---

# Hello World!

Hello from `elixir`:

    IO.inspect "Hello World!"
```
{% endraw %}

## First Post

Now that we have a good way of generating web pages, the same can be applied to
blog posts. The markdown files should be in `_posts` folder and have a name
with the following format:

```
<YYYY>-<MM>-<DD>-<name of the article>.md
```

where:

- `<YYYY>` is a four digit number representing the year.
- `<MM>` is a two digit number representing the month.
- `<DD>` is a two digit number representing the day.

e.g. `_posts/2019-05-29-example.md`.

For listing the posts, we could create an HTML file like  `blogs.html` with
the following contents:

{% raw %}
```markdown
---
layout: default
title: Blog
---
<h1>Latest Posts</h1>

<ul>
  {% for post in site.posts %}
    <li>
      <h2><a href="{{ post.url }}">{{ post.title }}</a></h2>
      <p>{{ post.description }}</p>
    </li>
  {% endfor %}
</ul>
```
{% endraw %}

## Time to Deploy

I used Circle CI for the deploy to Github. Though it was a little tricky, it
works perfectly. There are two main branches:

- `master`: Contains the blog itself (`_site` contents). It's Generated
  automatically by Circle CI runners.
- `gh-pages`: Jekyll project.

The idea is to always merge new blog posts into `gh-pages` and let the Circle
CI runners generate the `_site` and then commit its contents to the `master`
branch.

> **Note**: The following changes are split in several blocks of code, though
> they all belong in the same file: `.circleci/config.yml`.

First, we define the `build` stage where the objective is to build the project
and save the `_site` into a shared workspace in `/tmp/site`:

```yaml
version: 2.1
jobs:
  build:
    docker:
      - image: circleci/ruby:2.6
    working_directory: ~/repo
    steps:
      - checkout
      - run: gem install bundler
      - run: bundle install
      - run: bundle exec jekyll build
      - run: mkdir -p /tmp/site
      - run: cp -a _site/. /tmp/site
      - persist_to_workspace:
          root: /tmp/site
          paths:
            - .
```

Then, we define the `deploy` stage where the objective is to commit the
`/tmp/site` contents in the `master` branch:

```yaml
  deploy:
    docker:
      - image: circleci/ruby:2.6
    working_directory: /tmp/repo
    steps:
      - attach_workspace:
          at: /tmp/site
      - add_ssh_keys:
          fingerprints:
            - "$FINGERPRINT"
      - run: git config --global core.sshCommand 'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
      - run: git config --global user.email "$EMAIL"
      - run: git config --global user.name "$NAME"
      - run: git clone "$PROJECT" .
      - run: cp -a /tmp/site/. .
      - run: git add .
      - run: git commit -m "autogenerated commit"
      - run: git push origin master
```

The variables should be added in:

```
https://circleci.com/gh/<your user>/<your_user>.github.io/edit#env-vars
```

where:

- `$EMAIL` is your Github primary e-mail address.
- `$NAME` is your name.
- `$PROJECT` is `git@github.com/<your user>.github.io.git`
- `$FINGERPRINT` is the SSH key with read/write permissions that you would need
  to create and set in your project (see next section).

Finally, we only run this stages for `gh-pages` branch:

```yaml
workflows:
  version: 2
  blog:
    jobs:
      - build:
          filters:
            branches:
              only: gh-pages
      - deploy:
          requires:
            - build
          filters:
            branches:
              only: gh-pages
```

## Configuring SSH Key

The SSH key is needed for the runner to be able to commit the new changes to
master. Creating an SSH is easy:

```bash
ssh-keygen -t rsa -C "<github primary email>" -b 4096 -f blog
```

the previous command will generate two files:

- Public key `blog.pub`.
- Private key `blog`.

Having those two files, first, we need to do the following in Github:

- Copy the contents of `blog.pub`.
- Go to `https://github.com/<your user>/<your user>.github.io/settings/keys`
  in your Github project.
- Click in `Add deploy key`.
- Write the name of the key in `Title` field.
- Paste `blog.pub`'s contents to `Key` field.
- Tick the `Allow write access` checkbox.
- Click `Add key`.

Then, we need to do the following in Circle CI:

- Copy the contents of `blog`.
- Go to `https://circleci.com/gh/<your user>/<your user>.github.io/edit#ssh`
- Click in `Add SSH key`.
- Write `github.com` in `Hostname` field.
- Paste `blog`'s contents in `Private Key`.
- Click `Add SSH Key`.

## Conclusion

The hardest part is setting up the project, but then it becomes very easy to
maintain.
