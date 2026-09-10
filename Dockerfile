FROM ghcr.io/xtls/xray-core:latest

COPY config.template.json /etc/xray/config.template.json
COPY entrypoint.sh /entrypoint.sh

USER root
RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
