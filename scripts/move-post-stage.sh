#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <from:draft|queue> <to:queue|post> <slug-folder>"
  exit 1
fi

from="$1"
to="$2"
slug="$3"

case "$from" in
  draft) from_dir="_draft_posts" ;;
  queue) from_dir="_queue_posts" ;;
  *) echo "Invalid from stage: $from"; exit 1 ;;
esac

case "$to" in
  queue) to_dir="_queue_posts" ;;
  post) to_dir="_posts" ;;
  *) echo "Invalid to stage: $to"; exit 1 ;;
esac

src="$from_dir/$slug"

if [[ ! -d "$src" ]]; then
  echo "Source folder does not exist: $src"
  exit 1
fi

if [[ "$to" == "post" ]]; then
  date_prefix="$(date +%Y-%m-%d)"
  post_file="${date_prefix}-${slug}.md"
  if [[ ! -f "$src/index.md" ]]; then
    echo "Expected markdown entrypoint missing: $src/index.md"
    exit 1
  fi

  mv "$src/index.md" "_posts/$post_file"
  post_path="_posts/$post_file"
  mkdir -p "assets/post-assets/$slug"

  # Move remaining files as post assets.
  shopt -s dotglob nullglob
  for item in "$src"/*; do
    mv "$item" "assets/post-assets/$slug/"
  done
  shopt -u dotglob nullglob

  rmdir "$src"

  # Rewrite common local asset links in the published markdown so folder-based
  # drafts/queue docs do not require manual path edits on publish.
  # Handles markdown links/images, HTML src/href attributes, and frontmatter
  # image fields for:
  #   ./..., ../..., /drafts/<slug>/..., /queue/<slug>/...
  perl -0pi -e "s#\\]\\(\\./#](/assets/post-assets/$slug/#g; s#\\]\\(\\.\\./#](/assets/post-assets/$slug/#g; s#\\]\\(/drafts/$slug/#](/assets/post-assets/$slug/#g; s#\\]\\(/queue/$slug/#](/assets/post-assets/$slug/#g; s#(src|href)=\\\"\\./#\$1=\\\"/assets/post-assets/$slug/#g; s#(src|href)=\\\"\\.\\./#\$1=\\\"/assets/post-assets/$slug/#g; s#(src|href)=\\\"/drafts/$slug/#\$1=\\\"/assets/post-assets/$slug/#g; s#(src|href)=\\\"/queue/$slug/#\$1=\\\"/assets/post-assets/$slug/#g; s#^(\\s*image:\\s*[\"\\']?)\\./#\$1assets/post-assets/$slug/#mg; s#^(\\s*image:\\s*[\"\\']?)\\.\\./#\$1assets/post-assets/$slug/#mg; s#^(\\s*image:\\s*[\"\\']?)/drafts/$slug/#\$1assets/post-assets/$slug/#mg; s#^(\\s*image:\\s*[\"\\']?)/queue/$slug/#\$1assets/post-assets/$slug/#mg" "$post_path"

  echo "Published to _posts/$post_file"
  echo "Assets moved to assets/post-assets/$slug"
  echo "Updated local/collection asset links in $post_path to /assets/post-assets/$slug/..."
  echo "Reminder: verify uncommon custom links manually."
else
  mkdir -p "$to_dir"
  mv "$src" "$to_dir/$slug"
  echo "Moved $slug from $from_dir to $to_dir"
fi
