# Editing Kattenburg Atlas

For slide frontmatter and map settings, see the
[Slides authoring guide](https://github.com/allmaps/slides/blob/main/docs/authoring.md).
The notes below cover this repository's artwork and image sources.

## Credits logos

The institution logos live in `assets/logos/`, outside the IIIF source images.
They are transparent SVGs, served directly as vectors. `-light.svg` versions are
for light mode; `-dark.svg` versions use white elements for dark mode. SMF keeps
its colored emblem in both themes. The compact UvA mark is available as
`uva-small-light.svg` and `uva-small-dark.svg`; the credits use the full wordmark.

`CREDITS.md` uses ordinary `<img>` tags with `src` and `data-dark-src`
for each logo, without any imports. This follows the app's theme switch automatically and
works in any slide or credits document. The `logo-grid` class lays out the links
without text decoration or external-link icons; `logo-wide` spans both columns.

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

For simple captions, use an ordinary Markdown image with the same local path.
The [Slides image guide](https://github.com/allmaps/slides/blob/main/docs/images.md)
covers manifests, crops, rotation, accessibility and remote services.
The Pantserplaten slide demonstrates a cropped preview.

Link captions to the institution's object record and retain attribution and
rights information. Clicking an image opens a zoomable viewer with the same
caption. Slides disables the reusable component's download buttons.

Run `slides iiif` with this content directory after adding, replacing or removing
local source images. Remote IIIF services load in the browser and must support
CORS; the build does not copy their images into this repository.
