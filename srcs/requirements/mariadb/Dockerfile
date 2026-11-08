FROM debian:bookworm

RUN apt-get update -y && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

COPY scripts/mariadb_script.sh /tmp/script.sh
RUN chmod +x /tmp/script.sh

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

ENTRYPOINT ["/tmp/script.sh"]
CMD ["mysqld"]
