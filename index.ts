type MarkdownModule = {
  default: any;
  metadata: Record<string, unknown>;
};

const stripContentPrefix = <T>(files: Record<string, T>) =>
  Object.fromEntries(
    Object.entries(files).map(([key, value]) => [
      key.replace(/^\.\/content\//, "./"),
      value,
    ]),
  ) as Record<string, T>;

const rawProjectFiles = import.meta.glob("./content/*/project.yml", {
  eager: true,
  query: "?raw",
  import: "default",
}) as Record<string, string>;

const rawAssetUrls = import.meta.glob(
  [
    "./content/*/assets/**/*.{avif,AVIF,gif,GIF}",
    "./content/*/assets/**/*.{geojson,GEOJSON,json,JSON}",
    "./content/*/assets/**/*.{jpeg,JPEG,jpg,JPG,png,PNG}",
    "./content/*/assets/**/*.{svg,SVG,tif,TIF,tiff,TIFF,webp,WEBP}",
  ],
  { eager: true, query: "?url", import: "default" },
) as Record<string, string>;

const rawSlideFiles = import.meta.glob("./content/*/slideshows/**/*.md", {
  eager: true,
}) as Record<string, MarkdownModule>;

export const projectFiles = stripContentPrefix(rawProjectFiles);

export const assetUrls = stripContentPrefix(rawAssetUrls);

export const slideFiles = stripContentPrefix(rawSlideFiles);
