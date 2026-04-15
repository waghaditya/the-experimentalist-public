# the-experimentalist
The website hosting repo for www.experimentalist.in

## Editorial workflow: Draft -> Queue -> Post

This repository now supports a folder-based editorial workflow for handling
multiple in-progress posts in parallel:

- `_draft_posts/<slug>/index.md` + assets
- `_queue_posts/<slug>/index.md` + assets
- `_posts/YYYY-MM-DD-<slug>.md` for published posts

### Why this structure

Draft and queue content can be authored as self-contained folders so markdown
and assets stay together while editing and review happen in parallel.

### Local preview (includes draft + queue)

```bash
bundle exec jekyll serve --config _config.yml,_config.dev.yml
```

### Production build (publishes posts only)

```bash
bundle exec jekyll build --config _config.yml,_config.prod.yml
```

### Move content between stages

Use the helper script:

```bash
./scripts/move-post-stage.sh draft queue <slug>
./scripts/move-post-stage.sh queue post <slug>
```

Notes:
- `draft -> queue` keeps the same folder and relative asset links.
- `queue -> post` publishes markdown into `_posts/` and moves assets into
  `assets/post-assets/<slug>/`.
- During `queue -> post`, the script auto-rewrites common local links
  (`./...`, `../...`, `/drafts/<slug>/...`, `/queue/<slug>/...`) in markdown
  and HTML (`](/...)`, `src=`, `href=` forms), and frontmatter `image:`
  values.
  - Markdown/HTML links are rewritten to `/assets/post-assets/<slug>/...`.
  - Frontmatter `image:` is rewritten to `assets/post-assets/<slug>/...`.

### Legacy content compatibility

- Existing site content in `_posts`, `_pages`, and `assets/` remains valid and
  does not need to be reorganized.
- The draft/queue folder workflow is additive for new/in-progress posts.
- You can gradually adopt the new structure for new posts while keeping all old
  published content untouched.
