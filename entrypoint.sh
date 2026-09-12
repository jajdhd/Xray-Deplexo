#!/bin/sh
set -e

: "${PORT:=8080}"

# Xray config is fixed (internal-only ports 10001/10002, never touched by
# the platform's PORT), so it's copied as-is - no templating needed.
cp /etc/xray/config.template.json /etc/xray/config.json

# nginx is the only thing that needs to know the platform-assigned port
sed -e "s|__PORT__|$PORT|g" /etc/nginx.template.conf > /tmp/nginx.conf

echo "[entrypoint] Starting Xray (WS on /ws :10001, XHTTP packet-up on /xhttp :10002)"
xray run -config /etc/xray/config.json &

echo "[entrypoint] Starting nginx on port $PORT, routing /ws and /xhttp"
exec nginx -c /tmp/nginx.conf -g "daemon off;"
