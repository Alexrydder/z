#!/bin/bash
# Installs the podman quadlet units so Z starts at boot. Run as root once;
# re-run after editing deploy/*.container.
set -eu
umask 077
DBPW=$(grep '^DB_PASSWORD=' /srv/z/.env | cut -d= -f2-)
printf 'MYSQL_ROOT_PASSWORD=%s\nMYSQL_DATABASE=z\nMYSQL_USER=z\nMYSQL_PASSWORD=%s\n' "$DBPW" "$DBPW" > /srv/z/.db.env
mkdir -p /etc/containers/systemd
cat /srv/z/deploy/z-db.container > /etc/containers/systemd/z-db.container
cat /srv/z/deploy/z-web.container > /etc/containers/systemd/z-web.container
podman rm -f z-db z-web >/dev/null 2>&1 || true
systemctl daemon-reload
systemctl start z-db.service && sleep 15 && systemctl start z-web.service
systemctl --no-pager status z-db.service z-web.service | grep -E "Active|z-"
