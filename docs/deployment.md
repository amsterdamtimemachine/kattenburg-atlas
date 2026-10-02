# Deploy Kattenburg Atlas

Select **GitHub Actions** under **Settings → Pages**. Pushes to `main` install
the pinned `@allmaps/slides` package with `pnpm install --frozen-lockfile`, build
this repository and deploy `dist/site`. Pages supplies the URL and base path.

Both Pages and Docker use this repository's `package.json` and `pnpm-lock.yaml`.
To upgrade, run `pnpm add -D -E @allmaps/slides@<version>`, validate/build, and commit
both files. The Slides source repository and `SLIDES_REF` variable are no longer used.

## Container deployment

The [Dockerfile](../Dockerfile) builds and serves the
complete app in one multi-stage build. It installs the pinned Slides npm package,
Node 24 and the native renderer's Linux libraries, generates thumbnails and
IIIF derivatives, prerenders SvelteKit, then copies only the static site into
Nginx. No prebuilt Slides or renderer image is required.

From this content repository:

```sh
docker build -t kattenburg-atlas .
docker run --rm -p 8080:80 kattenburg-atlas
```

Open `http://localhost:8080`. Chapter URLs work on direct navigation as well as
through the app. Missing files return 404 instead of the home page.

Build arguments:

| Argument | Default | Purpose |
| --- | --- | --- |
| `PUBLIC_BASE_PATH` | empty | Serve at the origin root, or use a path such as `/atlas`. |
| `PUBLIC_URL` | content configuration | Override the canonical deployment URL at build time, including the base path if used. |
| `CACHE_EPOCH` | `0` | Change to force the build step to run again, allowing remote inputs to revalidate. CI supplies the UTC date. |

To build for the container deployment domain using an environment variable:

```sh
export PUBLIC_URL=https://kattenburg.amsterdamtimemachine.nl/
docker build \
  --build-arg CACHE_EPOCH="$(date -u +%F)" \
  --build-arg PUBLIC_URL \
  -t kattenburg-atlas .
```

`--build-arg PUBLIC_URL` passes the host environment variable into the build.
It overrides `site.publicUrl` without changing `slides.config.yml`.

The public URL is also the origin used for restricted basemap requests; the
configured provider key must permit that deployment origin. The site is static,
so public URL/base-path changes require rebuilding the image; setting
`docker run -e PUBLIC_URL=...` does not change the generated pages.

The separate `docker-publish.yml` workflow publishes both `linux/amd64` and
`linux/arm64` variants to GHCR under the same tags. Docker automatically selects
the matching variant, including on Apple Silicon and ARM64 servers. The static
site builds once on the runner's architecture; only the Nginx runtime varies.
Local `docker build` defaults to the host architecture. See Docker's
[multi-platform build documentation](https://docs.docker.com/build/building/multi-platform/).

`CONTAINER_BASE_PATH` and `CONTAINER_PUBLIC_URL` repository variables control the
container build settings. If `CONTAINER_PUBLIC_URL` is empty, `site.publicUrl`
in `slides.config.yml` supplies the URL. GitHub Pages uses its own configured URL.
Docker is not part of the Pages workflow.

## Build caches

Pages persists IIIF derivatives, remote annotations and thumbnail/map sources as
three independent Actions caches, with separate reset inputs. Its native
setup step installs the renderer's Ubuntu dependencies directly.
Downloaded inputs and completed derivatives are saved even if the site build
fails, so retrying it can reuse the work already done.

The Dockerfile mounts the same three cache directories with BuildKit. They stay
out of the serving image. Thumbnail recipes are additionally namespaced by the
content lockfile, so dependency changes cannot reuse incompatible rasters.
Changing `CACHE_EPOCH` reruns the build without discarding these caches. An
unchanged source generation reuses the finished thumbnails.

The image-publishing workflow uses explicit cache import/export for hosted
runners, in addition to the ordinary Docker layer cache. This is necessary
because [Docker's GitHub cache does not preserve cache mounts by default](https://docs.docker.com/build/ci/github-actions/cache/#cache-mounts).
