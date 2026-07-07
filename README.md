# txiki-alpine

Alpine-based txiki.js image for builds that need `tjs bundle` and `tjs compile`.

The image builds txiki.js from source once, stores the `tjs` executable at `/usr/local/bin/tjs`, and pre-warms the esbuild cache under `/opt/tjs` by setting `TJS_HOME=/opt/tjs`.

## Image Name

```text
ghcr.io/fy0/txiki-alpine:v26.6.0-alpine3.22
```

## Build Locally

```bash
docker build \
  -f Dockerfile \
  -t ghcr.io/fy0/txiki-alpine:v26.6.0-alpine3.22 \
  .
```

## Push Multi-Arch

```bash
docker buildx build \
  -f Dockerfile \
  --platform linux/amd64,linux/arm64 \
  --build-arg TJS_VERSION=v26.6.0 \
  --build-arg ALPINE_VERSION=3.22 \
  -t ghcr.io/fy0/txiki-alpine:v26.6.0-alpine3.22 \
  --push \
  .
```

## GitHub Actions

`.github/workflows/release.yml` publishes multi-arch images to GHCR:

- `ghcr.io/fy0/txiki-alpine:v26.6.0-alpine3.22` from `main`
- `ghcr.io/fy0/txiki-alpine:latest` from `v*` tags
- `ghcr.io/fy0/txiki-alpine:<version>-alpine3.22` from `v*` tags
- `ghcr.io/fy0/txiki-alpine:sha-<commit>` from every build

## Use As A Builder

```dockerfile
FROM ghcr.io/fy0/txiki-alpine:v26.6.0-alpine3.22 AS builder
WORKDIR /src
COPY . .
RUN tjs bundle --minify --sourcemap=inline src/main.ts build/app.bundle.js \
    && tjs compile build/app.bundle.js build/app
```
