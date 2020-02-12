---
layout: article
title: Syntax highlighting in Jekyll
description: Using Redcarpet markdown renderer to add pygments to Jekyll
handle: alex
image: jekyll.png
author: Alex de Sousa
---

This is mainly a programming blog. Big part of picking a static site generator
involved researching for code syntax highlighters. When I found these
[Pygments CSS themes](http://jwarby.github.io/jekyll-pygments-themes/languages/javascript.html)
I knew I wanted Pygments support in my static site generator.

Turns out Jekyll has amazing support for Pygments when used together with
Redcarpet markdown parser.

## Enter Redcarpet

Before using any of those CSS themes, first I needed to add `redcarpet` gem
to my `Gemfile` e.g:

```ruby
source "https://rubygems.org"

gem "jekyll"
gem "redcarpet"
```

After running `bundle install`, I added the configuration for `redcarpet` in
your `_config.yml`

```yaml
# _config.yml
markdown: redcarpet

... rest of the config ...
```

> Redcarpet has many useful extensions and you can find out more about them
> [here](https://github.com/vmg/redcarpet).

## Adding syntax highlighting theme to Jekyll

For [thebroken.link](https://thebroken.link) I downloaded the
[Monokai theme](https://raw.githubusercontent.com/jwarby/pygments-css/master/monokai.css)
for syntax highlighting.

I only needed to modify two files:

- `assets/css/main.css`: my main CSS file included in all my layouts, including
  `default`.
- `_includes/css/pygments/monokai.css`: Monokai theme I downloaded.

In order to include Monokai theme into into `assets/css/main.css`, I used
Liquid  directives:
{% raw %}
```css
---
---
{%- comment -%} File: assets/css/main.css {%- endcomment -%}

{%- include css/pygments/monokai.css -%}

... more styles ...

```
{% endraw %}

Having already included the file `assets/css/main.css` in my `default` layout,
I can do the following:

{% highlight markdown %}
{% raw %}
---
layout:default
---

# Lorem Ipsum

```elixir
IO.puts "Lorem Ipsum"
```
{% endraw %}
{% endhighlight %}

## Conclusion

Now you can have beautiful code in your programming posts!

![B-e-a-utiful!](https://media.giphy.com/media/i5wNCqyMzY2Oc/giphy.gif)

