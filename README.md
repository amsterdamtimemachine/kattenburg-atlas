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
