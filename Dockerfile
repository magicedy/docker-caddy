ARG DOCKER_REGISTRY=gcr.io

ARG DISTROLESS_NAME=static-debian12

FROM caddy:builder-alpine AS builder

ENV XCADDY_GO_BUILD_FLAGS="-ldflags '-w -s'"

RUN xcaddy build \
    --with github.com/caddy-dns/duckdns

RUN apk add --no-cache binutils \
    && strip /usr/bin/caddy

RUN apk add --no-cache upx \
    && upx --lzma --best /usr/bin/caddy

FROM ${DOCKER_REGISTRY}/distroless/${DISTROLESS_NAME}

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

ENTRYPOINT ["/usr/bin/caddy"]

CMD ["run", "--config", "/etc/caddy/Caddyfile"]