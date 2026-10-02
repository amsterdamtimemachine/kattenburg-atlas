# Kattenburg Atlas

Explore Kattenburg's maritime and military history through maps and stories.
This repository contains the content for an
[Allmaps Slides](https://github.com/allmaps/slides) website.

## Edit the atlas

- [slideshows](slideshows): chapters and map settings.
- [slides.config.yml](slides.config.yml): overall title, slideshows and interface text.
- [CREDITS.md](CREDITS.md): acknowledgements and institution logos.

See [editing notes](docs/editing.md) for local images and logos, and the
[Slides authoring guide](https://github.com/allmaps/slides/blob/main/docs/authoring.md)
for the Markdown format.

## Preview and build

Use Node.js 24 or later and pnpm 10. Run from this repository:

```sh
pnpm install --frozen-lockfile
pnpm dev
```

After editing, run `pnpm validate` and `pnpm build`. Builds generate local IIIF
images and map previews automatically. Use `pnpm exec slides iiif .` to refresh
local images during development.

Pushes to `main` run the [GitHub Pages workflow](.github/workflows/deploy-pages.yml).
The Slides version is pinned in `package.json` and `pnpm-lock.yaml`.
See [deployment](docs/deployment.md) for setup, upgrades and cache controls.
The deployment guide also covers the Docker image served with Nginx.
