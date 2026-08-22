#!/usr/bin/env bash
set -euo pipefail

if [ ! -d .slides-app/.git ]; then
  git clone --filter=blob:none --no-checkout https://github.com/allmaps/slides.git .slides-app
fi

if [ -L .slides-app/content ]; then
  rm .slides-app/content
fi

git -C .slides-app sparse-checkout init --no-cone
git -C .slides-app sparse-checkout set --no-cone "/*" "!/content/" "!/content/**"
git -C .slides-app checkout main
git -C .slides-app pull --ff-only

if [ -e .slides-app/content ] && [ ! -L .slides-app/content ]; then
  echo ".slides-app/content exists and is not a symlink; remove or re-clone .slides-app first." >&2
  exit 1
fi

rm -f .slides-app/content
ln -s ../content .slides-app/content

cd .slides-app
pnpm install
pnpm exec slides dev --config ../slides.config.yml
