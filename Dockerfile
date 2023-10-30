FROM caddy:builder-alpine AS builder

ENV XCADDY_GO_BUILD_FLAGS="-ldflags '-w -s'"

ENV CADDY_VERSION ="v2.7.5"

RUN xcaddy build \
    --with github.com/caddy-dns/duckdns

RUN apk add --no-cache binutils \
    && strip /usr/bin/caddy

RUN apk add --no-cache upx \
    && upx --lzma --best /usr/bin/caddy

FROM caddy:latest

COPY --from=builder /usr/bin/caddy /usr/bin/caddy