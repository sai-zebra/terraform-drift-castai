#!/bin/bash

set -e #Exits immediately if a command exits with a non-zero status

echo "updating instance"
yum update -y

echo "installing httpd"
yum install -y httpd

echo "changing httpd port to 8080"
sed -i -e 's/80/8080/' /etc/httpd/conf/httpd.conf

echo "adding message to index.html"
echo "I Hope Everyone has understood about Drift_Detection fell free to ask anything" > /var/www/html/index.html

echo "starting httpd"
systemctl restart httpd
systemctl enable httpd