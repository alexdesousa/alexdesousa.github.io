#!/bin/bash

ROOT_FOLDER=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

cd "$ROOT_FOLDER"

# Process images.
bash "$ROOT_FOLDER/build_images.sh"

# Build site.
bundle exec jekyll build --unpublished

OLD="$(cat "$ROOT_FOLDER/_config.yml" | md5sum | awk '{print $1}')"
NEW="$(cat "$ROOT_FOLDER/_site/config.yml" | md5sum | awk '{print $1}')"

# Copy new config.
if [ "$OLD" != "$NEW" ]; then
  echo "Old config checksum: $OLD"
  echo "New config checksum: $NEW"
  cp "$ROOT_FOLDER/_site/config.yml" "$ROOT_FOLDER/_config.yml"
fi

# Build CSS and JS.
npm run build

# Run server.
bundle exec \
  jekyll serve --livereload --unpublished --host=0.0.0.0 &&
  bundle exec \
    htmlproofer "$ROOT_FOLDER/_site" --disable-external=true
