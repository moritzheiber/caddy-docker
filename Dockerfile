ARG CADDY_VERSION="2.3.0"

FROM caddy:${CADDY_VERSION}-builder-alpine as builder

ARG DNS_PLUGIN_VERSION="1.1.1"

RUN xcaddy build \
  --with github.com/caddy-dns/route53@v${DNS_PLUGIN_VERSION}

FROM ghcr.io/moritzheiber/alpine:latest
LABEL maintainer="Moritz Heiber <hello@heiber.im>"
LABEL org.opencontainers.image.source=https://github.com/moritzheiber/caddy-docker

ENV CADDY_HOME="/caddy" \
  CADDYPATH="${CADDY_HOME}/certificates"

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

RUN apk --no-cache add ca-certificates libcap-ng-utils && \
  filecap /usr/bin/caddy net_bind_service && \
  addgroup -S caddy && \
  adduser -h ${CADDY_HOME} -s /bin/bash -SD caddy && \
  install -d -m0755 -o caddy -g caddy ${CADDYPATH} ${CADDY_HOME}/public && \
  apk --no-cache del --purge libcap-ng libcap-ng-utils

EXPOSE 80 443 2019
VOLUME ${CADDYPATH}
WORKDIR /caddy
USER caddy

CMD ["caddy","run"]
