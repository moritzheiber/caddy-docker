FROM moritzheiber/alpine-base:latest

ENV CADDY_VERSION="0.11.0" \
  CADDY_CHECKSUM="93e77bdbaba0a2b39f9e1de653d17ab1939491f7727948ec65750b4996d07c18" \
  CADDY_HOME="/caddy"

ENV CADDYPATH="${CADDY_HOME}/certificates"

RUN apk --no-cache add curl ca-certificates tar libcap-ng-utils && \
  curl -L https://github.com/mholt/caddy/releases/download/v${CADDY_VERSION}/caddy_v${CADDY_VERSION}_linux_amd64.tar.gz -o /tmp/caddy.tar.gz && \
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
