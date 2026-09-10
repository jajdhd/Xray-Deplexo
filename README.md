# Xray VLESS+WS (deploy-ready)

VLESS over WebSocket, no TLS baked into the container — the platform's
edge/subdomain already terminates HTTPS/TLS for you, so the container
only needs to speak plain WebSocket internally.

UUID and WebSocket path are fixed in `config.template.json` — no
environment variables to set. Just deploy.

- UUID: `ebd389ef-415e-439c-afb1-1ca5d6df3294`
- WS path: `/vless`

## Deploy

1. Push this repo to GitHub.
2. Connect it on your platform (Deplexo, Railway, Zeabur, Render, ...).
   It will detect the `Dockerfile` and build automatically.
3. Nothing else to configure — `PORT` is picked up automatically from
   the platform if it injects one, otherwise it defaults to `8080`.
4. Make sure the platform exposes port 443 (HTTPS) on your subdomain
   and proxies it to the container — this is normally automatic.

## Client config

Once you have your subdomain, use:

- Address: your subdomain (e.g. `yourapp.yourplatform.dev`)
- Port: `443`
- UUID: `ebd389ef-415e-439c-afb1-1ca5d6df3294`
- Encryption: `none`
- Network: `ws`
- Path: `/vless`
- TLS: `on`

Share link:

```
vless://ebd389ef-415e-439c-afb1-1ca5d6df3294@<your-subdomain>:443?encryption=none&security=tls&type=ws&host=<your-subdomain>&path=%2Fvless#myserver
```

Replace `<your-subdomain>` with the actual subdomain once deployed.

## Notes

- Keep the UUID private — anyone with it can use your proxy.
- Some platforms disallow proxy/VPN-type workloads in their Terms of
  Service — check before relying on this for anything long-term.
