FROM teddysun/xray:25.9.11

# nginx: reverse proxy in front of Xray
# tini: proper PID 1 init (signal forwarding + zombie reaping)
# curl: used by the container HEALTHCHECK
RUN apk add --no-cache nginx tini curl

COPY config_template.json /etc/xray/config.template.json
COPY nginx_template.conf /etc/nginx.template.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh \
    && mkdir -p /tmp/nginx_client_body /tmp/nginx_proxy /tmp/nginx_fastcgi /tmp/nginx_uwsgi /tmp/nginx_scgi

EXPOSE 8080

# Hits nginx's own "/" location, which only returns 200 once nginx is up.
# Doesn't prove Xray is alive (see entrypoint.sh for that supervision).
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -fsS "http://127.0.0.1:${PORT:-8080}/" || exit 1

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
