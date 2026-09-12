#!/bin/sh
set -e

: "${PORT:=8080}"
: "${CLIENT_UUID:=ebd389ef-415e-439c-afb1-1ca5d6df3294}"

# Runtime templates are rendered into /tmp because it's guaranteed writable
# regardless of which user the container runs as, or whether the image's
# root filesystem is mounted read-only. /tmp/xray is not created anywhere
# else in the image (only the nginx tmp dirs are), so it must be created
# here before anything is copied/written into it - otherwise `cp` below
# fails and, because of `set -e`, the whole script (and container) dies
# before Xray or nginx ever start.
mkdir -p /tmp/xray

# Client UUID is templated too now, so it doesn't have to be baked as
# plaintext into the built image - override it via the CLIENT_UUID env var.
sed -e "s|__UUID__|$CLIENT_UUID|g" /etc/xray/config.template.json > /tmp/xray/config.json

# nginx is the only thing that needs to know the platform-assigned port
sed -e "s|__PORT__|$PORT|g" /etc/nginx.template.conf > /tmp/nginx.conf

# --- process supervision -----------------------------------------------
# Plain `xray & ... ; exec nginx` means nginx (PID 1) survives a dead Xray
# and the container looks "healthy" while the proxy is actually down.
# Instead: start both, wait for whichever exits first, then kill the other
# and exit non-zero so the orchestrator (Docker/Fly/Render/etc.) restarts
# the container.

cleanup() {
    echo "[entrypoint] Shutting down..."
    kill -TERM "$xray_pid" "$nginx_pid" 2>/dev/null || true
    wait "$xray_pid" "$nginx_pid" 2>/dev/null || true
}
trap cleanup TERM INT

echo "[entrypoint] Starting Xray (WS on /ws :10001, XHTTP packet-up on /xhttp :10002)"
xray run -config /tmp/xray/config.json &
xray_pid=$!

echo "[entrypoint] Starting nginx on port $PORT, routing /ws and /xhttp"
nginx -e /tmp/nginx-error.log -c /tmp/nginx.conf -g "daemon off;" &
nginx_pid=$!

# Wait for either process to exit; -n needs a shell that supports it (ash/dash on
# Alpine's busybox do). If it's ever missing, this falls back to a polling loop.
if wait -n "$xray_pid" "$nginx_pid" 2>/dev/null; then
    exit_code=0
else
    exit_code=$?
    if [ "$exit_code" = 127 ] || [ "$exit_code" = 2 ]; then
        # `wait -n` unsupported: poll instead
        while kill -0 "$xray_pid" 2>/dev/null && kill -0 "$nginx_pid" 2>/dev/null; do
            sleep 1
        done
        exit_code=1
    fi
fi

if kill -0 "$xray_pid" 2>/dev/null; then
    echo "[entrypoint] nginx exited unexpectedly - stopping Xray"
else
    echo "[entrypoint] Xray exited unexpectedly - stopping nginx"
fi

cleanup
exit "${exit_code:-1}"
