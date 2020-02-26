---
layout: article
title: Markdown Cheatsheet
image: sea.png
description: Some of the things you can accomplish with the current blog configuration.
handle: alex
soundcloud: 721257316
published: false
---

This is a small cheatsheet of the things you can do with this blog layout:

{% include toc.html
   title = "Article Information"
   number = "I"
   image = "chapter.png"
%}
{% include toc.html
   title = "Chapter creation"
   number = "II"
   image = "chapter.png"
%}
{% include toc.html
   title = "Colors"
   number = "III"
   image = "chapter.png"
%}
{% include toc.html
   title = "Headers"
   number = "IV"
   image = "chapter.png"
%}
{% include toc.html
   title = "Enphasis"
   number = "V"
   image = "chapter.png"
%}
{% include toc.html
   title = "Lists"
   number = "VI"
   image = "chapter.png"
%}
{% include toc.html
   title = "Images"
   number = "VII"
   image = "chapter.png"
%}
{% include toc.html
   title = "Links"
   number = "VIII"
   image = "chapter.png"
%}
{% include toc.html
   title = "Youtube Videos"
   number = "IX"
   image = "chapter.png"
%}
{% include toc.html
   title = "Horizontal Lines"
   number = "X"
   image = "chapter.png"
%}
{% include toc.html
   title = "Quotes"
   number = "XI"
   image = "chapter.png"
%}
{% include toc.html
   title = "Tables"
   number = "XII"
   image = "chapter.png"
%}
{% include toc.html
   title = "Code Highlighting"
   number = "XIII"
   image = "chapter.png"
   chapter = "Bonus"
%}

{% include chapter.html number = 1 %}

An article starts with the following:

{% highlight markdown %}
{% raw %}
---
lang: en-US
layout: article
title: Markdown Cheatsheet
description: Some of the things you can accomplish with the current blog configuration.
image: sea.png
handle: alex
soundcloud: 473064099
published: false
---
{% endraw %}
{% endhighlight %}

where:

- `lang` is the language of the article. Defaults to `en-US`, but it can be
  changed to anything else as long is valid e.g. `es-ES`.
- `layout` is always `article`.
- `title` is the title of the article.
- `soundcloud` is the track id number (see embed link from the share option in
  the page).
- `description` is a short description of the article.
- `published` is a boolean value (`true` or `false`) for telling `Jekyll`
  whether the article should be published or not.
- `image` is the image that you'll see on the previews e-g. This article is
  called `2019-11-17-markdown-cheatsheet.md` so
  1. We need to create the folder `/assets/img/markdown-cheatsheet/`
  2. Place images inside it. In this example the value `sea.png` corresponds
     to the file `/assets/img/markdown-cheatsheet/sea.png`.
  3. If no image is found, it will use the default one.
- `handle` is the handle of the writer. For a working `handle` we need:
  1. A profile image in `/assets/img/handle/` named as the handle followed by
     `.jpg` e.g. `/assets/img/handle/alex.jpg`
  2. A bio present in `/_includes/bio/` named as the handle followed by `.html`
     e.g. `/_includes/bio/alex.html`
  3. If no profile picture is found, it will use the default image (Refill Aqua
     logo).
  4. If no `bio` is found, it won't appear.

{% include chapter.html number = 2 %}

If you want to divide an article in several chapters you need to:

- Add a Table of Contents (ToC).
- Add a chapter header identified by its number (the number depends on the
  order in the ToC).

### ToC

For the table of contents just add the following:

{% highlight markdown %}
{% raw %}
{% include toc.html
   title = "My Title"
   number = "I"
   chapter = "Bonus Content"
   image = "chapter.png"
   background_color = "var(--shore-blue)"
   color = "#000000"
%}
{% endraw %}
{% endhighlight %}

where the mandatory values are:

- `title` is the title of the chapter.
- `number` is the number of the chapter. It can be any word and does not
  affect order.
- `image` is an image in the article folder. The image has inverted colors,
  so try to use images with black lines and transparent backgrounds.

> The images should have a width of 300px.

There are some additional variables that can also be used:

- `chapter` are the words before the actual title. Defaults to
  `Chapter <number>:`, but can be overriden with this option. The example will
  generate `Bonus Content:`.
- `background_color` is the background of the chapter header. It can be any
  color valid in CSS. Defaults to `var(--deep-blue)`.
- `color` is the font color of the chapter header. It can be any color valid
  in CSS. Defaults to `var(--deep-blue)`.

### Chapter Header

After adding a ToC you can add a chapter header:

{% highlight markdown %}
{% raw %}
{% include chapter.html
   number = 1 %}
{% endraw %}
{% endhighlight %}

where `number` is the position of the chapter in the ToC.

{% include chapter.html number = 3 %}

All Refill Aqua Blog colors are present in variables across the CSS of the page.

<ul>
  <li>
    <code>var(--deep-blue)</code>
    <div style="background-color: var(--deep-blue); width: 10px; height: 10px; border-radius: 50%; margin-left: 5px;">
    </div>
  </li>
  <li>
    <code>var(--shore-blue)</code>
    <div style="background-color: var(--shore-blue); width: 10px; height: 10px; border-radius: 50%; margin-left: 5px;">
    </div>
  </li>
  <li>
    <code>var(--sky-blue)</code>
    <div style="background-color: var(--sky-blue); width: 10px; height: 10px; border-radius: 50%; margin-left: 5px;">
    </div>
  </li>
  <li>
    <code>var(--sand)</code>
    <div style="background-color: var(--sand); width: 10px; height: 10px; border-radius: 50%; margin-left: 5px;">
    </div>
  </li>
  <li>
    <code>var(--deep-gray)</code>
    <div style="background-color: var(--deep-gray); width: 10px; height: 10px; border-radius: 50%; margin-left: 5px;">
    </div>
  </li>
  <li>
    <code>var(--shore-gray)</code>
    <div style="background-color: var(--shore-gray); width: 10px; height: 10px; border-radius: 50%; margin-left: 5px;">
    </div>
  </li>
  <li>
    <code>var(--sky-gray)</code>
    <div style="background-color: var(--sky-gray); width: 10px; height: 10px; border-radius: 50%; margin-left: 5px;">
    </div>
  </li>
  <li>
    <code>var(--font-blue)</code>
    <div style="background-color: var(--font-blue); width: 10px; height: 10px; border-radius: 50%; margin-left: 5px;">
    </div>
  </li>
  <li>
    <code>var(--code-background)</code>
    <div style="background-color: var(--code-background); width: 10px; height: 10px; border-radius: 50%; margin-left: 5px;">
    </div>
  </li>
</ul>

{% include chapter.html number = 4%}

# H1 Header (the article header uses this, but it's styled differently)
## H2 Header (chapter header uses this)
### H3 Header
#### H4 Header
##### H5 Header
###### H6 Header

```markdown
## H2 Header
### H3 Header
#### H4 Header
##### H5 Header
###### H6 Header
```

{% include chapter.html number = 5 %}

Emphasis, aka italics, with *asterisks* or _underscores_.

Strong emphasis, aka bold, with **asterisks** or __underscores__.

Combined emphasis with **asterisks and _underscores_**.

Strikethrough uses two tildes. ~~Scratch this~~.

```markdown
Emphasis, aka italics, with *asterisks* or _underscores_.

Strong emphasis, aka bold, with **asterisks** or __underscores__.

Combined emphasis with **asterisks and _underscores_**.

Strikethrough uses two tildes. ~~Scratch this~~.
```

{% include chapter.html number = 6 %}

1. First ordered list item.
2. Another item.
   * Unordered sub-list.
   * Other element.
1. Actual numbers don't matter, just that it's a number.
   1. Ordered sub-list.
   2. Other element.
4. And another item.

     You can have properly indented paragraphs within list items. Notice the
     indentation at the beginning.

     This way you can write several paragraphs under the same list element.

This would be a normal paragraph.

* Unordered list can use asterisks
- Or minuses
+ Or pluses

```markdown
1. First ordered list item.
2. Another item.
   * Unordered sub-list.
   * Other element.
1. Actual numbers don't matter, just that it's a number.
   1. Ordered sub-list.
   2. Other element.
4. And another item.

     You can have properly indented paragraphs within list items. Notice the
     indentation at the beginning.

     This way you can write several paragraphs under the same list element.

This would be a normal paragraph.

* Unordered list can use asterisks
- Or minuses
+ Or pluses
```

{% include chapter.html number = 7%}

There are two ways of including images:

- Via markdown.
- Via include.

### Via Markdown

Use this for external images only.

```
![Google Logo](https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png)

```

![Google Logo](https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png)

### Via Include

Use this for the articles.

{% include image.html
   src = "sea.png"
   alt = "The Sea"
   caption = "Longer description of the sea."
%}

{% highlight markdown %}
{% raw %}
{% include image.html
   src = "sea.png"
   alt = "The Sea"
   caption = "Longer description of the sea."
%}
{% endraw %}
{% endhighlight %}

where:

- `sea.png` is in `/assets/img/markdown-cheatsheet/` folder.
- `alt` text is the alt of the image.
- `caption` text is the caption of the image.

> The images should have a width of 740px.

{% include chapter.html number = 8 %}

[I'm an inline-style link](https://refillaqua.com)

[I'm an inline-style link with title](https://refillaqua.com "Refill Aqua's Homepage")

```markdown
[I'm an inline-style link](https://refillaqua.com)

[I'm an inline-style link with title](https://refillaqua.com "Refill Aqua's Homepage")
```

{% include chapter.html number = 9 %}

For YouTube videos you need to include them with the following:

{% highlight markdown %}
{% raw %}
{% include youtube.html
   link="https://www.youtube.com/watch?v=9bZkp7q19f0"
%}
{% endraw %}
{% endhighlight %}

{% include youtube.html
   link="https://www.youtube.com/watch?v=9bZkp7q19f0"
%}

{% include chapter.html number = 10 %}

```markdown
---
```

produces:

---

{% include chapter.html number = 11 %}

The following quote

> This is a quote
>
> With several lines

is produced by:

{% highlight markdown %}
{% raw %}
> This is a quote
>
> With several lines
{% endraw %}
{% endhighlight %}

A more complex one would look like the following:

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis
nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

> Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
> incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis
> nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
>
> Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore
> eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt
> in culpa qui officia deserunt mollit anim id est laborum.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore
eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt
in culpa qui officia deserunt mollit anim id est laborum.

{% include chapter.html number = 12 %}

{% highlight markdown %}
{% raw %}
Food    | Description                           | Category | Sample type
------- | :-----------------------------------: | -------- | ----------:
Apples  | A small, somewhat round ...           | Fruit    | Fuji
Bananas | A long and curved, often-yellow ...   | Fruit    | Snow
Kiwis   | A small, hairy-skinned sweet ...      | Fruit    | Golden
Oranges | A spherical, orange-colored sweet ... | Fruit    | Navel
{% endraw %}
{% endhighlight %}

produces:

Food    | Description                           | Category | Sample type
------- | :-----------------------------------: | -------- | ----------:
Apples  | A small, somewhat round ...           | Fruit    | Fuji
Bananas | A long and curved, often-yellow ...   | Fruit    | Snow
Kiwis   | A small, hairy-skinned sweet ...      | Fruit    | Golden
Oranges | A spherical, orange-colored sweet ... | Fruit    | Navel

> Tip: use `:` to align elements in a column.

> Tables must be styled.

{% include chapter.html number = 13 %}

{% highlight markdown %}
{% raw %}
```elixir
IO.puts "Alex"
```
{% endraw %}
{% endhighlight %}

produces:

```elixir
IO.puts "Alex"
```
