#!/bin/sh
set -e

# platform injects PORT automatically on most hosts; default to 8080 if not set
: "${PORT:=8080}"

sed -e "s|__PORT__|$PORT|g" /etc/xray/config.template.json > /etc/xray/config.json

echo "[entrypoint] Listening on port $PORT, ws path /vless"

exec xray run -config /etc/xray/config.json
