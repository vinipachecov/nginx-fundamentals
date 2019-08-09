wget http://nginx.org/download/nginx-1.17.2.tar.gz
tar -zxvf  nginx-1.17.2.tar.gz  
cd nginx-1.17.2/
apt-get install build-essential  -y
apt-get install libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev -y
sudo ./configure 

sudo ./configure --sbin-path=/usr/bin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/home/nginx/error.log --http-log-path=/home/nginx/access.log --with-pcre --pid-path=/var/run/nginx.pid --with-http_ssl_module --with-http_image_filter_module=dynamic --modules-pat/usr/local/nginx/modules/ngx_http_image_filter_module.soc/nginx/modules

make
make install

