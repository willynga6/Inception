FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends vsftpd ftp\
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/vsftpd/empty

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY scripts/script.sh /tmp/script.sh
RUN  chmod +x /tmp/script.sh

EXPOSE 21 21100-21110
ENTRYPOINT ["/tmp/script.sh"]
CMD ["vsftpd", "/etc/vsftpd.conf"]
