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

## Images and captions

Use ordinary figures with `data-image` pointing to a local source image or an
IIIF Image API service (base URL or `info.json`). No component import is needed:

```md
<figure data-image="assets/images/stadsarchief-amsterdam/010056916960.jpg"
  aria-label="Gebouw langs de timmerwerf van het magazijn">

<figcaption>

Gebouw langs de timmerwerf van het magazijn. Collectie
[Stadsarchief Amsterdam](https://archief.amsterdam/beeldbank/detail/72659f71-f1f8-9fda-cd70-af3111809ac8).

</figcaption>
</figure>
```

For Presentation API manifests, use `data-manifest="https://…/manifest.json"`
instead. The first canvas is shown; set `data-canvas="https://…/canvas/2"` to
select another. Do not add a Markdown image inside an IIIF figure: Atlas loads
the image directly, without a separate fallback or generated `srcset`. Give the
figure an `aria-label` describing the image. Keep blank lines around Markdown
inside HTML tags.

Local images also support simple Markdown markup, with the alt text used as the
caption: `![Description](assets/images/stadsarchief-amsterdam/010056916960.jpg)`.
External IIIF resources require figure attributes. Ordinary external Markdown
images remain plain images with captions generated from their alt text.

Captions support links, emphasis and multiple paragraphs. Link to the institution's
object record and retain attribution and rights information. Clicking an image
opens a zoomable viewer with the same caption and source links overlaid.
Download buttons save the rendered preview or the current zoomed view as a PNG.

Use `#xywh=x,y,width,height` on `data-image`, or a `data-region="x,y,width,height"`
attribute, to crop the preview and set the viewer's opening region. Coordinates
use original image pixels; `percent:10,20,60,50` uses percentages. The same
attribute works with local derivatives. For manifests, put the fragment on
`data-canvas` (or `data-manifest` for the first canvas); coordinates then refer
to the canvas. The complete image remains available when zooming out.
The Pantserplaten slide demonstrates a cropped preview.

Local source images use the generated IIIF derivatives. Remote services are
loaded by the browser and must support CORS; no remote assets are imported into
this package by the site build. IIIF images require JavaScript. Their captions
remain available without it, and loading failures show a retry button.

## Build

```sh
pnpm exec slides build kattenburg-atlas
```

## Deployment

Pushes to `main` run the GitHub Pages workflow. It checks out `slides` at the workspace root, checks out this repository at `content/kattenburg-atlas`, builds `kattenburg-atlas`, and deploys `apps/slides/build`.

### Container deployment

The `Dockerfile`, based on the `container-build` prototype, builds and serves the
complete app in one multi-stage build. It obtains the Slides source, installs
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
| `SLIDES_REPO` | `https://github.com/allmaps/slides.git` | Framework source repository. |
| `SLIDES_REF` | `main` | Framework branch, tag or commit containing the extracted renderer. Pin a commit for a reproducible framework version. |
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

For local framework development, Docker supports replacing the `slides` source
stage with `--build-context slides=/path/to/source-only-slides-checkout`. Use a
source-only checkout without host `node_modules` or generated build directories.
This also allows testing framework changes before their commit is available on
the remote repository.

The separate `docker-publish.yml` workflow publishes both `linux/amd64` and
`linux/arm64` variants to GHCR under the same tags. Docker automatically selects
the matching variant, including on Apple Silicon and ARM64 servers. The static
site builds once on the runner's architecture; only the Nginx runtime varies.
Local `docker build` defaults to the host architecture. See Docker's
[multi-platform build documentation](https://docs.docker.com/build/building/multi-platform/).

`SLIDES_REF`, `CONTAINER_BASE_PATH` and `CONTAINER_PUBLIC_URL` repository variables
control its build settings. The Docker workflow defaults `PUBLIC_URL` to
`https://kattenburg.amsterdamtimemachine.nl/`; setting `CONTAINER_PUBLIC_URL`
overrides that default. GitHub Pages continues to use the URL in
`slides.config.yml`, builds with Node/pnpm directly and exports
`apps/slides/build`; Docker is not part of the Pages workflow.

### Build caches

Pages persists IIIF derivatives, remote annotations and thumbnail/map sources as
three independent Actions caches, with separate reset inputs. Its one native
setup command calls the renderer package's shared Ubuntu dependency script.
Downloaded inputs and completed derivatives are saved even if the site build
fails, so retrying it can reuse the work already done.

The Dockerfile mounts the same three cache directories with BuildKit. They stay
out of the serving image. Thumbnail recipes are additionally namespaced by the
framework lockfile, so dependency changes cannot reuse incompatible rasters.
Changing `CACHE_EPOCH` reruns the build without discarding these caches. An
unchanged source generation reuses the finished thumbnails.

The image-publishing workflow uses explicit cache import/export for hosted
runners, in addition to the ordinary Docker layer cache. This is necessary
because [Docker's GitHub cache does not preserve cache mounts by default](https://docs.docker.com/build/ci/github-actions/cache/#cache-mounts).
