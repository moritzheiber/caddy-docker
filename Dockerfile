FROM golang:1.13.0-alpine3.10 as builder

ARG CADDY_VERSION="v1.0.4"
ARG GO111MODULE="on"

ADD main.go /go/src/caddy-build/main.go
WORKDIR /go/src/caddy-build

RUN apk --no-cache add git build-base && \
  go mod init caddy && \
  go get -v github.com/caddyserver/caddy@${CADDY_VERSION} && \
  echo "Building ..." && \
  echo "replace github.com/h2non/gock => gopkg.in/h2non/gock.v1 v1.0.14" >> go.mod && \
  go build

FROM moritzheiber/alpine-base:latest
LABEL maintainer="Moritz Heiber <hello@heiber.im>"
LABEL org.opencontainers.image.source=https://github.com/moritzheiber/caddy-docker

ENV CADDY_HOME="/caddy" \
  CADDYPATH="${CADDY_HOME}/certificates"

COPY --from=builder /go/src/caddy-build/caddy /usr/bin/

RUN apk --no-cache add ca-certificates libcap-ng-utils && \
  filecap /usr/bin/caddy net_bind_service && \
  addgroup -S caddy && \
  adduser -h ${CADDY_HOME} -s /bin/bash -SD caddy && \
  install -d -m0755 -o caddy -g caddy ${CADDYPATH} ${CADDY_HOME}/public && \
  apk --no-cache del --purge libcap-ng libcap-ng-utils

EXPOSE 80 443 2015
VOLUME ${CADDYPATH}
WORKDIR /caddy
USER caddy

CMD ["caddy","-root","public"]
