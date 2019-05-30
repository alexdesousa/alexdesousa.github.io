# The Broken Link Blog

> Broken or dead link, a link that, having suffered link rot, points to a
> webpage or server that is no longer available on the World Wide Web.

This project is my personal blog. Maintaining a blog should be simple: writing
some content, adding some images if needed, commit the changes and that's it.
This is my solution to solve this problem.

## What's Wrong With Medium?

Nothing, really. Their business is to host blogs for free and then monetize the
contents others create. If something is free, you're the product.

The same happens with Github. Their business is to host code for free and
provide the tools (and tools for integrating more useful tools) so developers
are hooked. Again, if something is free, you're the product.

I chose hosting my blog in GitHub because:

- I can write my blog using the same tools I use for writing code: `vim`, `zsh`
  and `git`. I feel confortable in this cocoon I've created and I feel more
  creative inside of it.
- I have a backup by default in my computer. If somehow someone at GitHub
  decides my ideas shouldn't be heard, then I would have the content I've
  created. Censorship is sometimes a consequence of centralization.
- I don't like Medium's business model.

## Why Ruby?

I don't love Ruby. I also don't hate it. Howeverm, my professional experience
does not include Ruby. So... Why Jekyll?

- Amazing documentation.
- Easy to use.
- Awesome plugins.
- No need of Ruby knowledge or, at least, not too much.

## Installing Ruby

For installing Ruby, I used the same method I use for Elixir and Erlang: using
`asdf` (for more information about it just check the
[project's GitHub page](https://github.com/asdf-vm/asdf))

First, I installed the Ruby plugin and the latest version of the language for
the project

```bash
$ asdf plugin-add ruby    # For installing the plugin for Ruby
$ asdf install            # Installs the latest version for Ruby
```

Then, I installed `bundler` package:

```bash
$ gem install bundler
```

Finally, having `bundler` installed, I can init a new Ruby project:

```bash
$ bundle init
```

## Writing an Article

TODO
