FROM teddysun/xray:25.9.11

# nginx: reverse proxy in front of Xray
# tini: proper PID 1 init (signal forwarding + zombie reaping)
# curl: used by the container HEALTHCHECK
RUN apk add --no-cache nginx tini curl

COPY config_template.json /etc/xray/config.template.json
COPY nginx_template.conf /etc/nginx.template.conf
COPY entrypoint.sh /entrypoint.sh

# Create + own every writable path up front, as root, while we still can.
# "nginx" is the unprivileged user the apk nginx package already created.
RUN chmod +x /entrypoint.sh \
    && mkdir -p /tmp/nginx_client_body /tmp/nginx_proxy /tmp/nginx_fastcgi /tmp/nginx_uwsgi /tmp/nginx_scgi /tmp/xray \
    && chown -R nginx:nginx /tmp/nginx_client_body /tmp/nginx_proxy /tmp/nginx_fastcgi /tmp/nginx_uwsgi /tmp/nginx_scgi /tmp/xray

EXPOSE 8080

# Hits nginx's own "/" location, which only returns 200 once nginx is up.
# Doesn't prove Xray is alive (see entrypoint.sh for that supervision).
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -fsS "http://127.0.0.1:${PORT:-8080}/" || exit 1

# Run as non-root. nginx's master process only tries to chown its temp
# directories when it's running as root (euid 0) - on this platform that
# chown is blocked by the sandbox even though the process shows as root,
# which is exactly why nginx refused to start ("Operation not permitted").
# Staying non-root the whole time makes nginx skip that step entirely.
USER nginx

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
