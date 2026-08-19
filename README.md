# Kattenburg Atlas

This repository contains the content for a `slides` atlas. The application code
is pulled from [`allmaps/slides`](https://github.com/allmaps/slides) during the
GitHub Pages build, while this repository keeps only the atlas content.

## Local build

Prepare a temporary copy of the app:

```sh
bash scripts/prepare-slides-app.sh
```

Then install and build the app:

```sh
cd .slides-app
pnpm install
PUBLIC_URL=/kattenburg-atlas pnpm build
```

The content lives in `content/kattenburg-atlas`. Project assets can be placed in
`content/kattenburg-atlas/assets`, and are served by the app under
`/assets/kattenburg-atlas`.

## Deployment

Pushes to `main` run `.github/workflows/deploy-pages.yml`. The workflow clones
`allmaps/slides` with partial clone filtering and sparse checkout, overlays this
repository's `content/` folder, builds with `PUBLIC_URL=/kattenburg-atlas`, and
deploys the static build to GitHub Pages.

Set a repository variable named `SLIDES_REF` if the atlas should build against a
specific branch or tag of `allmaps/slides`. Set `PUBLIC_URL` if the site should
use a custom base path.
