FROM moritzheiber/alpine-base:latest

ENV CADDY_VERSION="0.10.10" \
  CADDY_CHECKSUM="b51a0b591a867542cfd51928062ce961308fc1ad433286829b868de476e3602d" \
  CADDYPATH="/caddy"

RUN apk --no-cache add curl ca-certificates tar && \
  curl -L https://github.com/mholt/caddy/releases/download/v${CADDY_VERSION}/caddy_v${CADDY_VERSION}_linux_amd64.tar.gz | tar xzf - -C /tmp caddy && \
  echo "${CADDY_CHECKSUM}  /tmp/caddy" | sha256sum -c - && \
  install -m0755 -o root -g root /tmp/caddy /usr/bin/caddy && \
  addgroup -S caddy && \
  adduser -h ${CADDYPATH} -s /bin/bash -SD caddy && \
  install -d -m0755 -o caddy -g caddy ${CADDYPATH}/.caddy ${CADDYPATH}/public && \
  apk del --purge curl tar

WORKDIR /caddy
USER caddy

CMD ["caddy","-root","public"]
