#!/bin/bash
set -e

cd /var/www/html

# 1. Attendre que MariaDB accepte les connexions de l'utilisateur WordPress
echo "Attente de mariadb..."
until mysql -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1;" >/dev/null 2>&1; do
    sleep 2
done
echo "mariadb est prêt."

# 2. Installer WordPress seulement s'il n'est pas déjà présent dans le volume
if [ ! -f wp-config.php ]; then
    wp core download --locale=fr_FR --allow-root

    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root

    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root

   wp post create \
    --post_title="My first article" \
    --post_content="This article is used to test WordPress comments." \
    --post_status=publish \
    --allow-root
fi

# 3. Attendre que Redis accepte les connexions
echo "Attente de redis..."
until (echo > /dev/tcp/redis/6379) 2>/dev/null; do
    sleep 1
done
echo "redis est prêt."

# 4. Configurer Redis (idempotent : rejouable à chaque démarrage)
wp config set WP_REDIS_HOST redis --allow-root
wp config set WP_REDIS_PORT 6379 --raw --allow-root
wp config set WP_REDIS_DATABASE 0 --raw --allow-root

wp plugin is-installed redis-cache --allow-root || wp plugin install redis-cache --activate --allow-root
wp plugin is-active redis-cache --allow-root || wp plugin activate redis-cache --allow-root
wp redis enable --allow-root || true

# BONUS Mise en place du plugin mailpit
mkdir -p /var/www/html/wp-content/mu-plugins
cat > /var/www/html/wp-content/mu-plugins/mailpit.php << 'EOF'
<?php
add_action('phpmailer_init', function ($phpmailer) {
    $phpmailer->isSMTP();
    $phpmailer->Host = 'mailpit';
    $phpmailer->Port = 1025;
    $phpmailer->SMTPAuth = false;
    $phpmailer->SMTPSecure = '';
    $phpmailer->SMTPAutoTLS = false;
});
EOF

# 5. Droits pour php-fpm (qui tourne sous www-data)
chown -R www-data:www-data /var/www/html

# 6. Lancer php-fpm comme processus principal
exec "$@"
