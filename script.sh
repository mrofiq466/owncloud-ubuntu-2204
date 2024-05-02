#php7
apt update
apt-get install -y language-pack-en-base 
export LC_ALL=en_US.UTF-8 
export LANG=en_US.UTF-8 
sudo apt -y install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo add-apt-repository ppa:ondrej/apache
sudo apt-get update
sudo apt -y install php7.4 libimage-exiftool-perl
sudo apt install -y gnupg2 php7.4-fpm php7.4-intl php7.4-ldap php7.4-imap php7.4-gd php7.4-pgsql php7.4-curl php7.4-xml php7.4-zip php7.4-mbstring php7.4-soap php7.4-gmp php7.4-bz2 php7.4-bcmath php7.4-mysql php7.4-common php7.4-json
sudo update-alternatives --set php /usr/bin/php7.4
php -v
sleep 5s

#owncloud https://software.opensuse.org//download.html?project=isv:ownCloud:server:10&package=owncloud-complete-files
echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/server:/10/Ubuntu_22.04/ /' | sudo tee /etc/apt/sources.list.d/isv:ownCloud:server:10.list
curl -fsSL https://download.opensuse.org/repositories/isv:ownCloud:server:10/Ubuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/isv_ownCloud_server_10.gpg > /dev/null
sudo apt update
sudo apt install owncloud-complete-files mariadb-server apache2

mysql --password=1234 --user=root --host=localhost << EOF
#create database ownclouddb;
#grant all privileges on ownclouddb.* to root@localhost identified by "1234";
flush privileges;
exit;
EOF
cd /var/www/owncloud
#alternatif create db
sudo -u www-data php occ  maintenance:install \
--database='mysql' --database-name='owncloud' \
--database-user='root' --database-pass='1234' \
--admin-user='admin' --admin-pass='password'

#apache2
cat <<'EOF'>> /etc/apache2/sites-available/owncloud.conf
Alias /owncloud "/var/www/owncloud/"

<Directory /var/www/owncloud/>
  Require all granted
  AllowOverride All
  Options FollowSymLinks MultiViews

  <IfModule mod_dav.c>
    Dav off
  </IfModule>
</Directory>
EOF

sudo a2ensite owncloud.conf
sudo a2dismod php*
sudo a2enmod php7.4 rewrite mime unique_id headers env dir
a2dissite 000-default.conf
sudo systemctl restart apache2

echo ===============================
echo
echo link http://<ip addr>/owncloud
echo user=admin password=password
echo
echo ===============================
