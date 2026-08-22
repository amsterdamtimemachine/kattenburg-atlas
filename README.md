# Kattenburg Atlas

This repository contains the content for a `slides` atlas. The application code
is pulled from [`allmaps/slides`](https://github.com/allmaps/slides) during the
GitHub Pages build, while this repository keeps only the atlas content.

## Local preview

Use a sparse checkout of the reusable `slides` source and link this repository's
content package into it:

```sh
git clone --filter=blob:none --no-checkout https://github.com/allmaps/slides.git .slides-app
git -C .slides-app sparse-checkout init --no-cone
git -C .slides-app sparse-checkout set --no-cone "/*" "!/content/" "!/content/**"
git -C .slides-app checkout main
if [ -e .slides-app/content ] && [ ! -L .slides-app/content ]; then
  echo ".slides-app/content exists and is not a symlink; remove or re-clone .slides-app first." >&2
  exit 1
fi
rm -f .slides-app/content
ln -s ../content .slides-app/content
cd .slides-app
pnpm install
pnpm exec slides dev --config ../slides.config.yml
```

While the dev server is running, edit files in this repository's `content/`
folder.

Refresh that sparse clone when you want the latest app code:

```sh
git -C .slides-app pull
```

## Local build

Build from the linked sparse checkout:

```sh
cd .slides-app
pnpm exec slides build --config ../slides.config.yml
```

The content lives in `content/kattenburg-atlas`. Project assets can be placed in
`content/kattenburg-atlas/assets`. The `content/` folder is also a workspace
package named `@allmaps/slides-content`.

## Deployment

Pushes to `main` run `.github/workflows/deploy-pages.yml`. The workflow clones
`allmaps/slides` with partial clone filtering and sparse checkout, installs the
workspace, builds with `slides.config.yml`, and deploys
`apps/slides/build` to GitHub Pages. During the build, this repository's
`content/` folder is symlinked into the Slides workspace.