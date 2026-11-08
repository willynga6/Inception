FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
 php-cli php-mysql wget ca-certificates && \
 rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/adminer \
 && wget -q -O /var/www/adminer/index.php \
 https://github.com/vrana/adminer/releases/download/v6.2.0/adminer-6.2.0-mysql.php

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer"]
