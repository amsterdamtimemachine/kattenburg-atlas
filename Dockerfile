# Build
FROM node:26-slim AS builder

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends git ca-certificates && \
    npm install -g pnpm@11 && \
    rm -rf /var/lib/apt/lists/*

ARG SLIDES_REPO=https://github.com/allmaps/slides.git
ARG SLIDES_REF=main

RUN git clone --depth 1 --branch ${SLIDES_REF} ${SLIDES_REPO} .

# Content
COPY . content/kattenburg-atlas/

# Deps
RUN pnpm install --frozen-lockfile && \
    pnpm exec slides build kattenburg-atlas

# Serve
FROM nginx:alpine AS runner

COPY --from=builder /app/apps/slides/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
