#!/bin/bash

CMSVALUE=$CMS
FILETEST=index.php

case $CMSVALUE in

wordpress)
  if [ -f /var/www/html/drupal/web/"$FILETEST" ] || [ -f /var/www/html/"$FILETEST" ]; then
    echo "Wordpress or another CMS already installed, Install nothing"
  else
    wget "https://wordpress.org/latest.zip"
    unzip '*.zip' -d /var/www/html
    mv wordpress/* .
    mv wordpress/.* .
    rm -r wordpress
    rm latest.zip
    sed -i '2 i if ($_SERVER["HTTP_X_FORWARDED_PROTO"] == "https") $_SERVER["HTTPS"]="on";' wp-settings.php
    chown -R 33:33 /var/www/html
  fi
    ;;

wordpress_hardening)
  if [ -f /var/www/html/drupal/web/"$FILETEST" ] || [ -f /var/www/html/"$FILETEST" ]; then
    echo "Wordpress or another CMS already installed, Install nothing"
    echo "Updating snuffleupagus if it's an error you have to remove snuffleupagus manually"
    rm /usr/local/etc/php/conf.d/snuffleupagus.rules
    rm /usr/local/etc/php/conf.d/docker-php-ext-snuffleupagus.ini
    wget "https://raw.githubusercontent.com/Elrondo46/apache-php/master/hardening/phptest.sh"
    sh phptest.sh
    rm phptest.sh
    rm -r /snuffleupagus
  else
    wget "https://raw.githubusercontent.com/Elrondo46/apache-php/master/hardening/phptest.sh"
    sh phptest.sh
    rm phptest.sh
    rm -r /snuffleupagus
    cd /var/www/html
    wget "https://wordpress.org/latest.zip"
    unzip '*.zip' -d /var/www/html
    mv wordpress/* .
    mv wordpress/.* .
    rm -r wordpress
    rm latest.zip
    sed -i '2 i if ($_SERVER["HTTP_X_FORWARDED_PROTO"] == "https") $_SERVER["HTTPS"]="on";' wp-settings.php
    chown -R 33:33 /var/www/html
    fi
    ;;

drupal)
  if [ -f /var/www/html/drupal/web/"$FILETEST" ] || [ -f /var/www/html/"$FILETEST" ]; then
    echo "Drupal or another CMS already installed, Install nothing"
    sed -i 's#/var/www/html#/var/www/html/drupal/web#g' /etc/apache2/sites-enabled/000-default.conf
  else
    wget -O composer-setup.php https://getcomposer.org/installer
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    composer create-project drupal/recommended-project drupal
    chown -R 33:33 /var/www/html/drupal/web
    sed -i '116i RewriteBase /' /var/www/html/drupal/web/.htaccess
    echo "RewriteEngine on" > /var/www/html/drupal/.htaccess
    echo "RewriteRule (.*) web/\$1 [L]" >> /var/www/html/drupal/.htaccess
    sed -i 's#/var/www/html#/var/www/html/drupal/web#g' /etc/apache2/sites-enabled/000-default.conf
   fi
;;

spip)
  if [ -f /var/www/html/drupal/web/"$FILETEST" ] || [ -f /var/www/html/"$FILETEST" ]; then
    echo "SPIP or another CMS already installed, Install nothing"
  else
    wget "https://files.spip.net/spip/archives/spip-v$SPIP_VERSION.zip"
    unzip spip-v"$SPIP_VERSION".zip -d /var/www/html
    sed -i 's/MyISAM/innodb/g' /var/www/html/ecrire/req/mysql.php
    mv htaccess.txt .htaccess
    chown -R 33:33 /var/www/html
  fi
;;

dotclear)
  if [ -f /var/www/html/drupal/web/"$FILETEST" ] || [ -f /var/www/html/"$FILETEST" ]; then
    echo "DotClear or another CMS already installed, Install nothing"
  else
   wget "https://download.dotclear.net/latest.zip"
   unzip latest.zip -d /var/www/html
   mv dotclear/* .
   mv dotclear/.* .
   rm -r dotclear
   chown -R 33:33 /var/www/html
  fi
;;

*)
  echo "No CMS Detected, continue without CMS but you can define this variable later"
esac

set -e

echo "account default" > /etc/msmtprc
echo "host $SMTP_HOST" >> /etc/msmtprc
echo "port $SMTP_PORT" >> /etc/msmtprc
echo "tls $SMTP_TLS" >> /etc/msmtprc
echo "tls_starttls $SMTP_STARTTLS" >> /etc/msmtprc
echo "from $SMTP_FROM"  >> /etc/msmtprc
echo "auth $SMTP_AUTH" >> /etc/msmtprc
echo "user $SMTP_USERNAME" >> /etc/msmtprc
echo "password $SMTP_USERNAME" >> /etc/msmtprc

exec apache2-foreground
