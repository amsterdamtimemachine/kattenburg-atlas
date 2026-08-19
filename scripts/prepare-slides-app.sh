#!/usr/bin/env bash
set -euo pipefail

SLIDES_REPOSITORY="${SLIDES_REPOSITORY:-https://github.com/allmaps/slides.git}"
SLIDES_REF="${SLIDES_REF:-main}"

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONTENT_REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
CONTENT_DIR="${CONTENT_DIR:-$CONTENT_REPO_ROOT/content}"
SLIDES_APP_DIR="${SLIDES_APP_DIR:-$CONTENT_REPO_ROOT/.slides-app}"
MARKER_FILE="$SLIDES_APP_DIR/.prepared-by-kattenburg-atlas"

if [[ ! -d "$CONTENT_DIR" ]]; then
  echo "Content directory not found: $CONTENT_DIR" >&2
  exit 1
fi

if [[ -z "$SLIDES_APP_DIR" || "$SLIDES_APP_DIR" == "/" || "$SLIDES_APP_DIR" == "$CONTENT_REPO_ROOT" ]]; then
  echo "Refusing to replace unsafe slides app directory: $SLIDES_APP_DIR" >&2
  exit 1
fi

if [[ -e "$SLIDES_APP_DIR" ]]; then
  if [[ ! -f "$MARKER_FILE" ]]; then
    echo "Refusing to replace existing directory without marker: $SLIDES_APP_DIR" >&2
    exit 1
  fi

  rm -rf "$SLIDES_APP_DIR"
fi

git clone --filter=blob:none --no-checkout "$SLIDES_REPOSITORY" "$SLIDES_APP_DIR"
git -C "$SLIDES_APP_DIR" sparse-checkout init --no-cone
git -C "$SLIDES_APP_DIR" sparse-checkout set --no-cone "/*" "!/content/" "!/content/**"
git -C "$SLIDES_APP_DIR" checkout "$SLIDES_REF"

mkdir -p "$SLIDES_APP_DIR/content"
rsync -a --delete "$CONTENT_DIR"/ "$SLIDES_APP_DIR/content"/
touch "$MARKER_FILE"

echo "Prepared slides app in $SLIDES_APP_DIR"
