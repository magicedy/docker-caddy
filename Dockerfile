ARG CADDY_VERSION="v2.7.5"
ARG DOCKER_REGISTRY=gcr.io
ARG DISTROLESS_NAME=static-debian12
ARG TARGETPLATFORM=linux/amd64

FROM caddy:builder-alpine AS builder

ENV XCADDY_GO_BUILD_FLAGS="-ldflags '-w -s'"
RUN xcaddy build ${CADDY_VERSION} \
    --with github.com/caddy-dns/duckdns
RUN apk add --no-cache binutils upx
RUN strip /usr/bin/caddy && \
    upx --lzma --best /usr/bin/caddy


FROM ${DOCKER_REGISTRY}/distroless/${DISTROLESS_NAME}

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY --from=ghcr.io/magicedy/healthcheck:latest /healthcheck /healthcheck
ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data
EXPOSE 80 443 443/udp 2019

CMD ["/usr/bin/caddy", "run", "--config", "/etc/caddy/Caddyfile"]