# syntax=docker/dockerfile:1
# One build produces the deployable site image; no prebuilt Slides image needed.
FROM scratch AS slides
ARG SLIDES_REPO=https://github.com/allmaps/slides.git
ARG SLIDES_REF=main
ADD ${SLIDES_REPO}#${SLIDES_REF} /

FROM node:24-bookworm-slim AS node
FROM ubuntu:24.04 AS dependencies
COPY --from=slides /packages/static-render/scripts/install-system-deps.sh /tmp/install-system-deps.sh
RUN sh /tmp/install-system-deps.sh && rm /tmp/install-system-deps.sh
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules/npm /usr/local/lib/node_modules/npm
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && npm install --global pnpm@10.22.0
WORKDIR /app
COPY --from=slides /package.json /pnpm-lock.yaml /pnpm-workspace.yaml ./
COPY --from=slides /packages ./packages
COPY --from=slides /apps ./apps
RUN mkdir -p content && pnpm install --frozen-lockfile

FROM dependencies AS builder
COPY . ./content/kattenburg-atlas/
ARG PUBLIC_BASE_PATH=
ARG PUBLIC_URL=
# Change this to re-run the build even when content and framework are unchanged.
# CI passes the current UTC day so remote sources can revalidate daily.
ARG CACHE_EPOCH=0
ENV PUBLIC_BASE_PATH=${PUBLIC_BASE_PATH}
ENV PUBLIC_URL=${PUBLIC_URL}
RUN --mount=type=cache,target=/app/apps/slides/.svelte-kit/iiif,sharing=locked \
    --mount=type=cache,target=/app/apps/slides/.svelte-kit/annotations,sharing=locked \
    --mount=type=cache,target=/app/apps/slides/.svelte-kit/thumbnails,sharing=locked \
    echo "Source cache generation: $CACHE_EPOCH" \
    && export SLIDES_THUMBNAILS_CACHE_ROOT="/app/apps/slides/.svelte-kit/thumbnails/$(sha256sum pnpm-lock.yaml | cut -c1-16)" \
    && xvfb-run -a pnpm exec slides build kattenburg-atlas \
    && mkdir -p "/site/${PUBLIC_BASE_PATH#/}" \
    && cp -a apps/slides/build/. "/site/${PUBLIC_BASE_PATH#/}/"

# Runtime contains static files and Nginx, without the build tools or caches.
FROM nginx:alpine AS runner
RUN rm -rf /usr/share/nginx/html/*
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /site/ /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
