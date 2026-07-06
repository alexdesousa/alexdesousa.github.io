#!/bin/bash
# Replaces jekyll-minimagick: processes source image directories with ImageMagick.
# Run once before `bundle exec jekyll build` when source images change.
#
# Outputs:
#   assets/images/         — logo, cover, preview images
#   assets/images/profile/ — author avatars
#   <slug>/                — full-size post images  (→ _site/<slug>/)
#   <slug>/small/          — thumbnail post images  (→ _site/<slug>/small/)

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if command -v magick >/dev/null 2>&1; then
  MAGICK=(magick)
elif command -v convert >/dev/null 2>&1; then
  MAGICK=(convert)
else
  echo "error: ImageMagick not found (need 'magick' or 'convert')" >&2
  exit 1
fi

resize_dir() {
  local src="$1" dest="$2" size="${3:-}"
  [ -d "$ROOT/$src" ] || return 0
  mkdir -p "$ROOT/$dest"
  shopt -s nullglob
  for img in "$ROOT/$src"/*.jpg "$ROOT/$src"/*.jpeg "$ROOT/$src"/*.png "$ROOT/$src"/*.gif "$ROOT/$src"/*.webp; do
    out="$ROOT/$dest/$(basename "$img")"
    if [ -n "$size" ]; then
      "${MAGICK[@]}" "$img" -strip -resize "${size}>" "$out"
    else
      cp "$img" "$out"
    fi
  done
  shopt -u nullglob
}

resize_dir ".logo"    "assets/images"
resize_dir ".cover"   "assets/images"           "1080"
resize_dir "profiles" "assets/images/profile"   "100"

for post_dir in "$ROOT/_posts"/*/; do
  slug="$(basename "$post_dir")"
  resize_dir "_posts/$slug" "$slug"       "800"
  resize_dir "_posts/$slug" "$slug/small" "400"
done
