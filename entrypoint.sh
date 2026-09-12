#!/bin/sh
set -e

: "${PORT:=8080}"

# render Xray config with the platform-assigned port
sed -e "s|__PORT__|$PORT|g" /etc/xray/config.template.json > /etc/xray/config.json

echo "[entrypoint] Xray starting on port $PORT, path /vless (XHTTP transport)"

exec xray run -config /etc/xray/config.json
