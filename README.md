# The Broken Link Website

> Broken or dead link, a link that, having suffered link rot, points to a
> webpage or server that is no longer available on the World Wide Web.

This project is my personal blog. Maintaining a blog should be simple: writing
some content, adding some images if needed, commit the changes and that's it.
This is my solution to solve this problem.

# New to Jekyll

I don't love Ruby. I also don't hate it. But my professional experience does
not include Ruby. So... Why Jekyll?

- Amazing documentation.
- Easy to use.
- Awesome plugins.
- No need of Ruby knowledge.

# Building the Webpage

For building the webpage, we need to:

1. Install the supported Ruby version:

   ```bash
   $ asdf install # Installs the version in .tools-version
   ```

2. Install the dependencies:

   ```bash
   $ bundle # If it does not exist run gem install bundler
   ```

3. Build the webpage:

   ```bash
   $ bundle exec jekyll build # This generates the folder _site with the site
   ```

4. (Optional) Test it with the test server:

   ```bash
   $ bundle exec jekyll serve # Visit localhost:4000 in your machine.
   ```
