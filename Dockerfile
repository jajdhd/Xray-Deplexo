FROM teddysun/xray

COPY config.template.json /etc/xray/config.template.json
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
