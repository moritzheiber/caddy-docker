FROM moritzheiber/alpine-base:latest

ENV CADDY_VERSION="0.10.11" \
  CADDY_CHECKSUM="0223f50845201060ca0f455fb438e1523c6ec2230eae784325118ba8e85e569b" \
  CADDY_HOME="/caddy"

ENV CADDYPATH="${CADDY_HOME}/certificates"

RUN apk --no-cache add curl ca-certificates tar libcap-ng-utils && \
  curl -L https://github.com/mholt/caddy/releases/download/v${CADDY_VERSION}/caddy_v${CADDY_VERSION}_linux_amd64.tar.gz | tar xzf - -C /tmp caddy && \
  echo "${CADDY_CHECKSUM}  /tmp/caddy" | sha256sum -c - && \
  install -m0755 -o root -g root /tmp/caddy /usr/bin/caddy && \
  filecap /usr/bin/caddy net_bind_service && \
  addgroup -S caddy && \
  adduser -h ${CADDY_HOME} -s /bin/bash -SD caddy && \
  install -d -m0755 -o caddy -g caddy ${CADDYPATH} ${CADDY_HOME}/public && \
  apk del --purge curl tar libcap-ng

VOLUME ${CADDYPATH}
WORKDIR /caddy
USER caddy

CMD ["caddy","-root","public"]
