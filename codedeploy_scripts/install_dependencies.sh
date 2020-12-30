#!/bin/bash

apt-get update
apt-get install -y apache2
rm -f /var/www/html/index.html