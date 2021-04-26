FROM newfuture/ddns:v2.9.10

COPY service.sh /service.sh
RUN chmod +x /service.sh && apk add jq && rm -rf /var/cache/apk/* /tmp/*

CMD ["/service.sh"]
