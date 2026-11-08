FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        mariadb-client \
        php-fpm \
        php-cli \
        php-mysql \
        php-curl \
        php-gd \
        php-mbstring \
        php-xml \
        php-zip \
        php-intl \
    && rm -rf /var/lib/apt/lists/*

# wp-cli : sert à télécharger et configurer WordPress au démarrage
RUN curl -fsSL -o /usr/local/bin/wp \
        https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# php-fpm écoute sur le port 9000 (et non sur un socket Unix)
RUN sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf \
    && mkdir -p /run/php

COPY scripts/wordpress_script.sh /tmp/script.sh
RUN chmod +x /tmp/script.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/tmp/script.sh"]
CMD ["php-fpm8.2", "-F"]
