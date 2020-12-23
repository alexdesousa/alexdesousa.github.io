---
layout: post
lang: en
ref: "markdown-cheatsheet"
title: "Markdown Cheatsheet"
description: "Some of the things we can accomplish with the current blog configuration."
image: turtle.jpg
image_link: "https://unsplash.com/photos/IBEXUZBmlXg"
image_author: "Tanguy Sauvin"
handle: alex
soundcloud: 721257316
published: false
---

This is a small cheatsheet for creating articles using `Jekyll` and the blog
layout and utilities I've prepared:

{% include toc.html title = "Articles" %}
{% include toc.html title = "Authors" %}
{% include toc.html title = "Basic Markdown" %}
{% include toc.html title = "Table of Contents" %}
{% include toc.html title = "Images with Captions" %}
{% include toc.html title = "Youtube Videos" %}
{% include toc.html prefix = "Bonus" title = "Code Highlighting" %}

{% include chapter.html %}

When writing posts for this blog, we'll only need to work in the `_posts/`
folder. In this folder, we'll find all published and unpublished articles along
with all their images.

### Article Name

Articles should be named following this format:

```
_posts/<Year>-<Month>-<Day>-<Name of the article for the URL>.md
```

where:

- `<Year>` is the year the article was created e.g. `2020`.
- `<Month>` is the month the article was created e.g. `12` for December.
- `<Day>` is the day the article was created e.g. `12` for the twelfth day of
the month.
- `<Name of the article>` is the name of the article in the URL. We shoudl used
lowercase letters, don't use special characters (`ñ`, `á`, `ó`, `ł`, etc.), and
replace spaces with dashes (`-`) e.g. for an article written on 23rd of July of
2020 with the title _Julio libre de plástico_, the correct naming should be
something along the line of the following:

```
_posts/2020-07-23-julio-libre-de-plastico.md
```

### Article Header

Every article should start with the following header:

{% highlight markdown %}
{% raw %}
---
layout: post
lang: en
ref: "markdown-cheatsheet"
title: "Markdown Cheatsheet"
description: "Some of the things we can accomplish with the current blog configuration."
image: turtle.jpg
image_link: "https://unsplash.com/photos/IBEXUZBmlXg"
image_author: "Tanguy Sauvin"
handle: alex
soundcloud: 721257316
published: false
---
{% endraw %}
{% endhighlight %}

where:

| Name           | Description | Mandatory? |
| :------------- | :--- | :--- |
| `layout`       | Should be always `post` | Yes |
| `lang`         | Language of the page: `en` for English or `es` for Spanish | No, but defaults to `en` |
| `ref`          | Unique identifier used identify translations e.g `"markdown-cheatsheet"` is the reference for both English (this article) and the Spanish version. | No, but it's recommended |
| `title`        | Title of the article in the article's language. | Yes |
| `description`  | Description of the article in the article's language. | Yes |
| `image`        | Header image in any resolution, but preferably 4:3 in ratio. | Yes |
| `image_link`   | Header original image link | No |
| `image_author` | Header image author | No |
| `handle`       | Author's handle (see {% include ref.html title = "Authors" -%}) | No, but it's recommended |
| `published`    | Whether the article is published or not: `true` or `false` | No, but defaults to `true` |
| `soundcloud`   | Number of the Soundcloud recording for the article's content. | No |

### Article Images

All images including the article's cover image, should be in a folder of with
the same name of the article without the date and `md` extension e.g. for the
article `_posts/2020-07-23-julio-libre-de-plastico.md` the images should be in:

```
_posts/julio-libre-de-plastico/
```

For more information on how to add images to the article check the section
{% include ref.html title = "Images with Captions" %}.

### Article Helpers

There are several article helpers for different purposes. They are found in
the `_includes` folder and, in general, we shouldn't modify them to avoid
breaking other articles.

The general representation is as follows:

{% highlight markdown %}
{% raw %}
{% include <Name of the include>
   <option 1> = <value 1>
   <option 2> = <value 2>
   ...
   <option n> = <value n>
%}
{% endraw %}
{% endhighlight %}

We'll see several of these helpers in the rest of the article:

- {% include ref.html title = "Table of Contents" %}
- {% include ref.html title = "Images with Captions" %}
- {% include ref.html title = "Youtube Videos" %}

{% include chapter.html %}

For creating, updating or deleting an author we'll need to edit the file
`_data/authors.yml`. This file is in `YAML` format, so the syntax must be
preserved/used in order for this edit to work.

### Adding an Author

Let's say we want to add the author _Alice Allison_ to our blog. Her handle
is going to be `alice`, so we add her as follows:

```
... rest of the file ...
alice:
  name: "Alice Allison"
  bio:
    en: "This is a description of Alice in English."
    es: "Esta es una descripción de Alice en castellano."
```

Adding `bio`s in both English and Spanish is not necessary. Just add the `bio`
in the language of the article this author is writing.

### Adding a Profile Picture

For adding a profile picture, just add it to `profiles`, preferably in JPG
format. The name of the file should be the name of the author's handle followed
by the image extension e.g for Alice Allison it would be `alice.jpg`.

{% include chapter.html%}

Markdown is a simplified language for writing documents. This language can then
be converted to styled HTML.

### Headers

There are different sizes for the headers:

```markdown
# H1 Header
## H2 Header
### H3 Header
#### H4 Header
##### H5 Header
###### H6 Header
```

The previous will produce the following:

# H1 Header
## H2 Header
### H3 Header
#### H4 Header
##### H5 Header
###### H6 Header

where:

- `# ` or H1 header: it shouldn't be used because is already used in the title
of the article.
- `## ` or H2 header: it's used for chapters (see
{% include ref.html title = "Table of Contents" %}). If we're using chapters in
an article, we should use `### ` or H3 header instead.

### Text Styling

It's possible to do some minor text styling using basic markdown primitives:

- `_Text Emphasis_` or `*Text Emphasis*` will produce _Text Emphasis_.
- `**Text Bold**` or `__Text Bold__` will produce **Text Bold**.
- `~~Strikethrough Text~~` will produce ~~Strikethrough Text~~.

By mixing `~`, `*` and `_` we can accomplish a mix of styles e.g.
something like `**Mix _Styling_ ~~Text~~**` will produce
**Mix _Styling_ ~~Text~~**.

### Lists

There are two types of lists: ordered and unordered. They can be mixed together
or used alone.

#### Unordered Lists

For unordered lists we can use any of `-`, `+` or `*` followed by a space and
the item in the list. For nested lists use spaces in multiples of two e.g:

```markdown
- Apples:
  * Green
    + Girona: 2
    + Regular: 3
  * Red
    + Pink Lady: 2
- Pinapple: 1
```

will produce:

- Apples:
  * Green
    + Girona: 2
    + Regular: 3
  * Red
    + Pink Lady: 2
- Pinapple: 1

#### Ordered Lists

For ordered lists we can use a number followed by a `.` e.g. `1. `. It's not
necessary to increment the number, but it's recommended for readability. Same
as unordered lists, for nexted lists use spaces in multiples of two e.g:

```markdown
1. Heat water in a pot.
2. When the water is boiling, put the pasta.
3. Wait for 5 minutes:
   1. Remove the pot from the fire.
   2. Put the pasta in a strainer.
4. Serve the pasta.
5. Put tomato sauce on top.
```

will produce:

1. Heat water in a pot.
2. When the water is boiling, put the pasta.
3. Wait for 5 minutes:
   1. Remove the pot from the fire.
   2. Put the pasta in a strainer.
4. Serve the pasta.
5. Put tomato sauce on top.

### External Links

The syntax for external links is as follows:

```markdown
[<Text>](<Link>)
```

or

```markdown
[<Text>](<Link> <Tooltip Text>)
```

where:

  - `<Text>`: Is the text of the link.
  - `<Link>`: Is the external link including the protocol e.g. `https//`.
  - `<Tooltip Text>`: Is the text when we hover over the link.

For example, the following:

```markdown
Visit [Refill Aqua](https://refillaqua.com "Refill Aqua Webpage") and find out
how we're reducing plastic pollution in Barcelona.
```

will produce:

> Visit [Refill Aqua](https://refillaqua.com "Refill Aqua Webpage") and find
> out how we're reducing plastic pollution in Barcelona.

### External Images

The syntax for external images (JPG, PNG, GIFs, etc.) is as follows:

```markdown
![<Alt Text>](<Link>)
```

where:

  - `<Alt Text>`: Is the alt text of the image.
  - `<Link>`: Is the external link including the protocol e.g. `https//`.

For example, the following:

```markdown
![Refill Aqua Logo](https://refillaqua.com/assets/img/refill-aqua.png)
```

will produce:

![Refill Aqua Logo](https://refillaqua.com/assets/img/refill-aqua.png)

### Quotes

Quotes can be a single sentence or several paragraphs. They need to have `> `
at the beginning of every line e.g. the following:

```markdown
> Reducing plastic pollution one bottle at the time.
>
> \- Refill Aqua.
```

will produce:

> Reducing plastic pollution one bottle at the time.
>
> \- Refill Aqua.

### Tables

Our markdown version also has support for tables e.g. the following:

{% highlight markdown %}
{% raw %}
|  Left          |  Center      | Right            |
| :------------- | :----------: | ---------------: |
| This column is | This column  | This column      |
| aligned left   | is centered  | is aligned right |
{% endraw %}
{% endhighlight %}

will produce:

|  Left          |  Center      | Right            |
| :------------- | :----------: | ---------------: |
| This column is | This column  | This column      |
| aligned left   | is centered  | is aligned right |

where the header separators indicate the column's alignment:

- `:----` will align it left.
- `:---:` will center it.
- `----:` will align it right.

### Separators

Markdown also supports a basic separator which is an horizontal line to split
sections e.g. the following:

```markdown
Some text.

---

Some other text.
```

will produce:

Some text.

---

Some other text.

{% include chapter.html %}

If we want to divide an article in several chapters, we would need to:

- Add a Table of Contents (ToC).
- Add a chapter header every time we want to start a chapter from the ToC.

### Table of Contents

The helper is named `toc.html` and every instance will generate an entry in the
ToC e.g. the following generated the ToC for this article until this chapter:

{% highlight markdown %}
{% raw %}
{% include toc.html title = "Articles" %}
{% include toc.html title = "Authors" %}
{% include toc.html title = "Basic Markdown" %}
{% include toc.html title = "Table of Contents" %}
... more chapters ...
{% endraw %}
{% endhighlight %}

The following are some of the parameters we can use:

| Parameter     | Description |
| :------------ | :--- |
| `title`       | Chapter title. |
| `prefix`      | Prefix for the chapter title. |
| `is_decimal`  | Whether the chapter number should be in decimal or not: `true` or `false`. By default it'll be in roman numerals. |
| `image`       | Image for the chapter. Must be a black and white picture. |

This helper generates the title of the chapter depending on the parameters,
so it's easier to see every possible case:

- For `Chapter I`:

{% highlight markdown %}
{% raw %}
{% include toc.html %}
{% endraw %}
{% endhighlight %}

- For `Chapter I: My Title`:

{% highlight markdown %}
{% raw %}
{% include toc.html title = "My Title" %}
{% endraw %}
{% endhighlight %}

- For `Bonus: My Title`:

{% highlight markdown %}
{% raw %}
{% include toc.html prefix = "Bonus" title = "My Title" %}
{% endraw %}
{% endhighlight %}

- For `My Title`:

{% highlight markdown %}
{% raw %}
{% include toc.html prefix = "" title = "My Title" %}
{% endraw %}
{% endhighlight %}

- For `Chapter 1`:

{% highlight markdown %}
{% raw %}
{% include toc.html is_decimal = true %}
{% endraw %}
{% endhighlight %}

If `prefix = ""` and there's no `title`, the helper is not able to generate a
title, so it will error.

> **Note**: The generated prefixes are localized and depend on the `lang` value
> in the article header (see {% include ref.html title = "Articles" %}
> for more information).

### Chapter Header

After adding a ToC, we can add chapter headers. It's as easy as doing the
following before every new chapter:

{% highlight markdown %}
{% raw %}
{% include chapter.html %}
{% endraw %}
{% endhighlight %}

### Referencing a Chapter

Sometimes it's necessary to reference other sections within the same article.
This is done by referencing the title of the chapter to be referenced e.g. if we
would like to reference this chapter, we would do the following:

{% highlight markdown %}
{% raw %}
For more information about ToC see {% include ref.html title = "Table of Contents" %}.
{% endraw %}
{% endhighlight %}

And this will produce something like:

> For more information about ToC see {% include ref.html title = "Table of Contents" %}.

When the chapters do not have a `title`, the reference is done with the prefix
either is generated by the ToC or not e.g. given the following ToC entry:

{% highlight markdown %}
{% raw %}
{% include toc.html %}
{% endraw %}
{% endhighlight %}

It's possible to reference it with:

{% highlight markdown %}
{% raw %}
{% include ref.html title = "Chapter I" %}
{% endraw %}
{% endhighlight %}

as long as `I` represents the position in the ToC.

{% include chapter.html%}

The images with captions need to be downloaded into the article's folder
(see {% include ref.html title = "Articles" %} for more info) e.g.
for this article we have the image `_posts/markdown-cheatsheet/turtle.jpg`, so
to include it we would do the following:

{% highlight markdown %}
{% raw %}
{% include image.html
   src = "turtle.jpg"
   alt = "The Turtle"
   caption = "Longer description of **the tutle.**"
%}
{% endraw %}
{% endhighlight %}

where:

| Parameter | Description |
| :-------- | :--- |
| `src`     | Name of the image. |
| `alt`     | Alt text for the image. |
| `caption` | Cation for the image. It supports basic markdown (see {% include ref.html title = "Basic Markdown" %} for more information) |

The previous example will produce the following:

{% include image.html
   src = "turtle.jpg"
   alt = "The Turtle"
   caption = "Longer description of **the turtle.**"
%}

{% include chapter.html %}

YouTube videos can be added with a helper e.g. the following:

{% highlight markdown %}
{% raw %}
{% include youtube.html
   link="https://www.youtube.com/watch?v=9bZkp7q19f0"
%}
{% endraw %}
{% endhighlight %}

will produce:

{% include youtube.html
   link="https://www.youtube.com/watch?v=9bZkp7q19f0"
%}

{% include chapter.html %}

Though it's part of the basic markdown, syntax highlight is not going to be
used that much for this blog. There are two types: inline and block.

### Inline Syntax Highlighting

Sometimes it might be useful to highlight certain words e.g. the following:

```markdown
The word `highlighted` is highlighted.
```

will produce:

> The word `highlighted` is highlighted.

### Block Syntax Highlighting

It's used mainly for blocks of code, we have seen in this article e.g. the
following:

{% highlight markdown %}
{% raw %}
```elixir
IO.puts "Alex"
```
{% endraw %}
{% endhighlight %}

will produce the following block highlighted for `elixir` language:

```elixir
IO.puts "Alex"
```
