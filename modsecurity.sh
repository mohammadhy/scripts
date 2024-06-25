#! /bin/bash
echo "Install Req"
apt-get update
apt-get install -y apt-utils autoconf automake build-essential git libcurl4-openssl-dev libgeoip-dev liblmdb-dev libpcre++-dev libtool libxml2-dev libyajl-dev pkgconf wget zlib1g-dev
echo "Download And Compole ModeSecurity"
git clone https://github.com/SpiderLabs/ModSecurity
cd ModSecurity
git submodule init
git submodule update
./build.sh
./configure
make
make install
cd ..
echo "Download Nginx Connector"
git clone  https://github.com/SpiderLabs/ModSecurity-nginx.git
wget http://nginx.org/download/nginx-"$1".tar.gz
tar -zxvf nginx-"$1".tar.gz
cd nginx-"$1"
./configure --with-compat --add-dynamic-module=../ModSecurity-nginx
make modules
cp objs/ngx_http_modsecurity_module.so usr/share/nginx/modules
cd ..
echo "Configure Enable ModeSecurity"
mkdir -p /etc/nginx/modsec
wget -P /etc/nginx/modsec/ https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/modsecurity.conf-recommended
mv /etc/nginx/modsec/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
cp /ModSecurity/unicode.mapping /etc/nginx/modsec
sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsec/modsecurity.conf
