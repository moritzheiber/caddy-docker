FROM moritzheiber/alpine-base:latest

ARG CADDY_CHECKSUM="184ee35f71547743816e54dca77a5549d06553191212c23bdeb552cde6abdeaf"
ARG LICENSE="personal"
ARG PLUGINS="tls.dns.route53"

ENV CADDY_HOME="/caddy" \
  CADDY_VERSION="0.11.0"


ENV CADDYPATH="${CADDY_HOME}/certificates"

RUN apk --no-cache add curl ca-certificates tar libcap-ng-utils && \
  curl -L "https://caddyserver.com/download/linux/amd64?plugins=${PLUGINS}&license=${LICENSE}&telemetry=off" -o /tmp/caddy.tar.gz && \
  echo "${CADDY_CHECKSUM}  /tmp/caddy.tar.gz" | sha256sum -c - && \
  tar xzf /tmp/caddy.tar.gz -C /usr/bin caddy && \
  filecap /usr/bin/caddy net_bind_service && \
  addgroup -S caddy && \
  adduser -h ${CADDY_HOME} -s /bin/bash -SD caddy && \
  install -d -m0755 -o caddy -g caddy ${CADDYPATH} ${CADDY_HOME}/public && \
  apk del --purge curl tar libcap-ng

VOLUME ${CADDYPATH}
WORKDIR /caddy
USER caddy

CMD ["caddy","-root","public"]
