#!/bin/sh

PORT=${PORT:-80}

echo "===================="
echo "Xray Config Loaded"
echo "PORT: $PORT"
echo "UUID: 8f3a2b1c-9d4e-4f6a-b7c8-1e2d3f4a5b6c"
echo "XHTTP Path: /xhttp-7k9m2p4q (mode: packet-up)"
echo "WS Path: /ws-3n8v5x1z"
echo "===================="

exec /usr/local/bin/xray run -c /etc/xray/config.json
