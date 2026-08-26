# Kattenburg Atlas

Content package for [`allmaps/slides`](https://github.com/allmaps/slides).

## Local preview

Clone `slides`, add this repository as a content package, and run the dev server with the package name:

```sh
git clone https://github.com/allmaps/slides.git
cd slides
git submodule add https://github.com/amsterdamtimemachine/kattenburg-atlas.git content/kattenburg-atlas
pnpm install
pnpm exec slides dev kattenburg-atlas
```

Edit the files in `content/kattenburg-atlas/` while the dev server is running.

## Build

```sh
pnpm exec slides build kattenburg-atlas
```

## Deployment

Pushes to `main` run the GitHub Pages workflow. It checks out `slides` at the workspace root, checks out this repository at `content/kattenburg-atlas`, builds `kattenburg-atlas`, and deploys `apps/slides/build`.
