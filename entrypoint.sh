#!/bin/sh
set -e

: "${PORT:=8080}"

# --- render Xray config with the platform-assigned port ---
sed -e "s|__PORT__|$PORT|g" /etc/xray/config.template.json > /etc/xray/config.json

# --- start Xray (normal, everyday path) ---
xray run -config /etc/xray/config.json &
XRAY_PID=$!
echo "[entrypoint] Xray started (pid $XRAY_PID) on port $PORT, path /vless"

# --- start the Bale emergency-tunnel creator, only if cookies were provided ---
if [ -n "$BALE_COOKIES_B64" ]; then
  echo "$BALE_COOKIES_B64" | base64 -d > /tmp/bale-cookies.json

  : "${BALE_RESOURCES:=moderate}"
  echo "[entrypoint] Bale resources level: $BALE_RESOURCES"

  /usr/local/bin/headless-bale-creator \
    --cookies /tmp/bale-cookies.json \
    --write-file /tmp/join-link.txt \
    --resources "$BALE_RESOURCES" &
  BALE_PID=$!
  echo "[entrypoint] Bale emergency-tunnel creator started (pid $BALE_PID)"

  # print the join link to the logs as soon as it's written, and keep
  # printing it if it ever changes (new session, cookie refresh, etc.)
  ( while [ ! -f /tmp/join-link.txt ]; do sleep 1; done
    tail -f /tmp/join-link.txt | while read -r line; do
      echo "[entrypoint] BALE JOIN LINK: $line"
    done ) &
else
  echo "[entrypoint] BALE_COOKIES_B64 not set - emergency tunnel disabled, Xray-only mode"
fi

# keep the container alive as long as Xray (the primary, everyday path) is running
wait "$XRAY_PID"
