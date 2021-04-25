FROM alpine:latest

COPY ddns_v2.9.10 /root/app/ddns
COPY service.sh /root/app/
RUN chmod +x /root/app/service.sh /root/app/ddns && \
    apk add jq && rm -rf /var/cache/apk/* /tmp/*

CMD ["/root/app/service.sh"]
