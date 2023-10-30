ARG DOCKER_REGISTRY=gcr.io

ARG DISTROLESS_NAME=static-debian12

FROM caddy:builder-alpine AS builder

ENV CADDY_VERSION="v2.7.5"

ENV XCADDY_GO_BUILD_FLAGS="-ldflags '-w -s'"

RUN xcaddy build \
    --with github.com/caddy-dns/duckdns

RUN apk add --no-cache binutils \
    && strip /usr/bin/caddy

RUN apk add --no-cache upx \
    && upx --lzma --best /usr/bin/caddy

FROM ${DOCKER_REGISTRY}/distroless/${DISTROLESS_NAME}

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp
EXPOSE 2019

CMD ["/usr/bin/caddy", "run", "--config", "/etc/caddy/Caddyfile"]