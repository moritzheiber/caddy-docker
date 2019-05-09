package main

import (
	_ "github.com/caddyserver/dnsproviders/route53"
	"github.com/mholt/caddy/caddy/caddymain"
)

func main() {
	caddymain.EnableTelemetry = false
	caddymain.Run()
}
