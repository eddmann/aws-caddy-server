#!/bin/bash

cat > Caddyfile <<EOF
${domain} {
  root /var/www/${domain}
  tls ${email}
}
EOF
sudo mv Caddyfile /etc/caddy/Caddyfile
sudo chown root:root /etc/caddy/Caddyfile
sudo chmod 644 /etc/caddy/Caddyfile

while [ ! -e "/dev/xvdg" ]; do sleep 1; done
if [ "$(sudo file -b -s /dev/xvdg)" == "data" ]; then
  sudo mkfs -t ext4 /dev/xvdg
fi
echo '/dev/xvdg /data ext4 defaults,nofail 0 2' >> /etc/fstab
sudo mkdir /data
sudo mount /dev/xvdg /data
sudo mkdir /data/www /data/ssl

sudo ln -s /data/ssl /etc/ssl/caddy
sudo chown -R root:www-data /etc/ssl/caddy /data/ssl
sudo chmod 770 /etc/ssl/caddy /data/ssl

sudo ln -s /data/www /var/www
sudo chown -R www-data:www-data /var/www /data/www
sudo chmod 555 /var/www /data/www

sudo mkdir -p /var/www/${domain}
sudo chown -R www-data:www-data /var/www/${domain}
sudo chmod 555 /var/www/${domain}

sudo systemctl enable caddy.service
sudo systemctl start caddy.service
