FROM golang:1-alpine as builder
LABEL maintainer="Moritz Heiber <hello@heiber.im>"

ARG CADDY_VERSION="0.11.0"

WORKDIR /go/src

RUN apk --no-cache add git && \
  git clone --depth 1 --branch "v${CADDY_VERSION}" https://github.com/mholt/caddy.git github.com/mholt/caddy && \
  go get -u github.com/caddyserver/builds && \
  # Enable the Route53 DNS provider
  sed -i '/imported)/a\\t_ "github.com/caddyserver/dnsproviders/route53"' github.com/mholt/caddy/caddy/caddymain/run.go && \
  # Disable Telemetry
  sed -i 's/EnableTelemetry\ =\ true/EnableTelemetry\ =\ false/g' github.com/mholt/caddy/caddy/caddymain/run.go

WORKDIR /go/src/github.com/mholt/caddy/caddy
RUN go get ./... && \
  go run build.go goos=linux

FROM moritzheiber/alpine-base:latest
LABEL maintainer="Moritz Heiber <hello@heiber.im>"

ENV CADDY_HOME="/caddy" \
  CADDYPATH="${CADDY_HOME}/certificates"

COPY --from=builder /go/src/github.com/mholt/caddy/caddy/caddy /usr/bin/

RUN apk --no-cache add ca-certificates libcap-ng-utils && \
  filecap /usr/bin/caddy net_bind_service && \
  addgroup -S caddy && \
  adduser -h ${CADDY_HOME} -s /bin/bash -SD caddy && \
  install -d -m0755 -o caddy -g caddy ${CADDYPATH} ${CADDY_HOME}/public && \
  apk --no-cache del --purge libcap-ng

EXPOSE 80 443 2015
VOLUME ${CADDYPATH}
WORKDIR /caddy
USER caddy

CMD ["caddy","-root","public"]
