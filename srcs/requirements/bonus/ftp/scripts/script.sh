#!/bin/bash
set -e

# Utilisateur FTP : même UID que www-data (33) pour pouvoir modifier les fichiers WordPress
if ! id "$FTP_USER" &>/dev/null; then
    useradd -o -u 33 -g www-data -d /var/www/html -s /bin/bash "$FTP_USER"
fi

echo "$FTP_USER:$FTP_PASS" | chpasswd

mkdir -p /var/run/vsftpd/empty

exec "$@"
