FROM teddysun/xray

RUN apk add --no-cache curl ca-certificates && \
    curl -L -o /usr/local/bin/headless-bale-creator \
      https://github.com/kulikov0/whitelist-bypass-iran/releases/download/v0.1.2/headless-bale-creator-linux-x64 && \
    chmod +x /usr/local/bin/headless-bale-creator && \
    mkdir -p /app

COPY config.template.json /etc/xray/config.template.json
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
