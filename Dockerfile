# syntax=docker/dockerfile:1

ARG ALPINE_VERSION=3.22
ARG TJS_VERSION=v26.6.0

FROM alpine:${ALPINE_VERSION} AS builder
ARG TJS_VERSION
ENV TJS_HOME=/opt/tjs
WORKDIR /src
RUN apk add --no-cache build-base cmake git libffi-dev \
    && git clone --branch "${TJS_VERSION}" --depth 1 --recurse-submodules --shallow-submodules \
        https://github.com/saghul/txiki.js.git txiki.js \
    && make -C txiki.js \
    && mkdir -p "${TJS_HOME}" \
    && ./txiki.js/build/tjs bundle ./txiki.js/tests/helpers/bundle-input.js /tmp/tjs-warmup.js \
    && rm -f /tmp/tjs-warmup.js \
    && chmod -R a+rX "${TJS_HOME}"

FROM alpine:${ALPINE_VERSION}
ARG TJS_VERSION
ARG ALPINE_VERSION
ENV TJS_HOME=/opt/tjs
LABEL org.opencontainers.image.title="txiki.js Alpine"
LABEL org.opencontainers.image.description="txiki.js runtime and bundler on Alpine Linux"
LABEL org.opencontainers.image.source="https://github.com/fy0/password-auth-service"
LABEL org.opencontainers.image.version="${TJS_VERSION}-alpine${ALPINE_VERSION}"
RUN apk add --no-cache ca-certificates libffi libstdc++
COPY --from=builder /src/txiki.js/build/tjs /usr/local/bin/tjs
COPY --from=builder /opt/tjs /opt/tjs
RUN tjs --version >/dev/null \
    && printf 'console.log("txiki-alpine smoke");\n' > /tmp/smoke.js \
    && tjs bundle /tmp/smoke.js /tmp/smoke.bundle.js >/dev/null \
    && rm -f /tmp/smoke.js /tmp/smoke.bundle.js
ENTRYPOINT ["tjs"]
CMD ["--help"]
