# Kattenburg Atlas

This repository contains the content for a `slides` atlas. The application code
is pulled from [`allmaps/slides`](https://github.com/allmaps/slides) during the
GitHub Pages build, while this repository keeps only the atlas content.

## Local preview

Start a local development server:

```sh
bash scripts/dev.sh
```

This prepares `.slides-app` with `content/` symlinked back to this repository,
installs dependencies on the first run, and starts Vite. While the server is
running, edit files in this repository's `content/` folder and refresh the page
or let Vite reload it.

For local basemap tiles, add `PUBLIC_PROTOMAPS_KEY=...` to an untracked `.env`
file in this repository. The GitHub Pages workflow reads the same name from a
GitHub repository variable.

Run the preparation script again without starting the dev server:

```sh
bash scripts/prepare-slides-app.sh --link-content --reuse
```

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

Set repository variables named `SLIDES_REF` or `PUBLIC_URL` if the atlas should
build against a specific branch/tag or custom base path. Set
`PUBLIC_PROTOMAPS_KEY` to pass the Protomaps key into the deployed static app.
Set `PUBLIC_SLIDES_SINGLE_PROJECT_ROOT=true` to publish the single atlas project
at the site root instead of under `/:project`.
