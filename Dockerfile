FROM teddysun/xray

RUN apk add --no-cache nginx

COPY config.template.json /etc/xray/config.template.json
COPY nginx.template.conf /etc/nginx.template.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
