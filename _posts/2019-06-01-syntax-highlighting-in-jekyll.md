---
layout: article
title: Syntax highlighting in Jekyll
description: Using Redcarpet markdown generator to add pygments to Jekyll
handle: alex
image: syntax-highlighting-in-jekyll
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
`_config.yml` e.g:

```yaml
markdown: redcarpet
redcarpet:
  extensions: [
    "no_intra_emphasis",
    "superscript"
  ]
```

where:

- `"no_intra_emphasis"`: do not parse emphasis inside of words. Strings such as
  `foo_bar_baz` will not generate `<em>` tags.
- `"superscript"`: parse superscripts after the `^` character; contiguous
  superscripts are nested together, and complex values can be enclosed in
  parenthesis, e.g. `this is the 2^(nd) time`.

> **Note**: For more information about `redcarpet` you can go to the project's
> [page](https://github.com/vmg/redcarpet).

## Adding CSS to Jekyll

For [thebroken.link](https://thebroken.link) I downloaded the
[Monokai theme](https://raw.githubusercontent.com/jwarby/pygments-css/master/monokai.css)
to `assets/css/pygments/monokai.css` and then imported it to my main CSS file
`assets/css/main.css`:

```css
@import url(pygments/monokai.css);

pre {
  white-space: pre;
  overflow-x: auto;
}

code {
  color: #FFFFFF;
  background-color: #272822;
  padding: 4px 5px 4px 5px;
  border-radius: 3px;
  font-size: 15px;
}
```

And then added it to `_includes/head.html` (which is the file that generates
the `<head>` tag of my blog):

{% raw %}
```html
<head>
  <link rel="stylesheet" href="{{ "/assets/css/main.css?version=20190601" | prepend: site.baseurl }}">
</head>
```
{% endraw %}

Finally, this include can be included in a layout e.g `_layouts/default.html`
would look like:

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

And the layout now can be used as follows:

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
