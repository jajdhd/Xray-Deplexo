# Xray VLESS+XHTTP (deploy-ready, CDN-chain friendly)

VLESS over XHTTP (Xray's modern successor to WebSocket), no TLS baked into
the container — the platform's edge/subdomain (Deplexo) and any CDN in
front of it (Cloudflare, ArvanCloud, etc.) already terminate HTTPS/TLS for
you, so the container only needs to speak plain HTTP internally.

XHTTP was chosen over WebSocket specifically because it survives being
proxied through multiple CDN layers (e.g. ArvanCloud in front of
Cloudflare in front of Deplexo) much more reliably than WebSocket's
Upgrade handshake, which is easily broken by caching rules or
intermediate proxies that don't fully understand WS.

UUID and path are fixed in `config.template.json` — no environment
variables to set. Just deploy.

- UUID: `ebd389ef-415e-439c-afb1-1ca5d6df3294`
- Path: `/vless`
- Transport: `xhttp` (mode: auto)

## Deploy

1. Push this repo to GitHub.
2. Connect it on Deplexo (or any Docker-based platform). It will detect
   the `Dockerfile` and build automatically.
3. Nothing else to configure — `PORT` is picked up automatically from
   the platform if it injects one, otherwise it defaults to `8080`.
4. Make sure the platform exposes port 443 (HTTPS) on your subdomain and
   proxies it to the container — this is normally automatic.

## Client config

- Address: your subdomain (e.g. `yourapp.yourplatform.dev`, or a CDN
  domain in front of it)
- Port: `443`
- UUID: `ebd389ef-415e-439c-afb1-1ca5d6df3294`
- Encryption: `none`
- Network: `xhttp` (some clients call this `splithttp`)
- Path: `/vless`
- TLS: `on`

Share link:

```
vless://ebd389ef-415e-439c-afb1-1ca5d6df3294@<your-domain>:443?encryption=none&security=tls&type=xhttp&host=<your-domain>&path=%2Fvless#myserver
```

Replace `<your-domain>` with your actual domain. Note: your client app
needs XHTTP/splithttp support (recent v2rayNG, NekoBox, Hiddify all
support it).

## Optional: fronting through a CDN

`cloudflare-worker.js` / `wrangler.toml` — a Cloudflare Worker that
reverse-proxies to the Deplexo origin, with a `/` health-check endpoint
for uptime monitors (pings origin, always answers 200).

`arvancloud-worker.js` — the same idea for ArvanCloud Edge Computing, if
you want to additionally front through a domestic CDN.

If chaining CDNs (e.g. ArvanCloud → Cloudflare → Deplexo), make sure
caching is fully disabled / bypassed for the domain — a cached response
on the `/vless` path will break the tunnel intermittently.

## Notes

- Keep the UUID private — anyone with it can use your proxy.
- Some platforms disallow proxy/VPN-type workloads in their Terms of
  Service — check before relying on this for anything long-term.
