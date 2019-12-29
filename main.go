package main

import (
	"github.com/caddyserver/caddy/caddy/caddymain"
	_ "github.com/caddyserver/dnsproviders/route53"
	_ "github.com/hacdias/caddy-webdav"
)

func main() {
	caddymain.EnableTelemetry = false
	caddymain.Run()
}
