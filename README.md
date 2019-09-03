# Nginx Fundamentals

This is a compilation of what I've learned from Nginx when taking the course "Nginx Fundamentals: High Performance Servers from Scratch" by Ray Viljoen.

Nginx was created to have a better performance than apache server. At the time apache handled the basic idea of a single request at a time, in other words, synchronously.

Nginx process was designed to handle request asynchronously. It can handle multiple requests at once instead of waiting a first request to handle a second one.
This is called concurrent request.

Resources:

- [Install the source of nginx](#install-the-source-of-nginx)
- [Usage of this repo](#how-to-use-it)
- [About Location](#location-directive)
- [Variables](#Variables)
- [Setting variables](#Setting-variables)
- [Args validation](#Args-validation)
- [Redirects](#Redirects)
- [Rewrites](#Rewrites)
- [Try files](#Try-files)
- [HTTP2](#HTTP2)

## Install the source of nginx

```.sh
wget http://nginx.org/download/nginx-1.17.2.tar.gz
tar -zxvf  nginx-1.17.2.tar.gz
cd nginx-1.17.2/
apt-get install build-essential  -y
apt-get install libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev -y
sudo ./configure

sudo ./configure --sbin-path=/usr/bin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/home/nginx/error.log --http-log-path=/home/nginx/log/nginx/access.log --with-pcre --pid-path=/var/run/nginx.pid

make
make install
```

## Usage of this repo

Create a /site folder in your root and move the /demo folder into it.

## About Location

We have three location matches

1. Exact Match
2. Preferential Prefix Match
3. REGEX Match

```conf
 server {
    listen 80;
    server_name localhost;
    root /sites/demo;

    #  Preferential prefix match
    location ^~  /Greet5 {
      return 200 "Hello from NGINX 'greet' location";
    }


    # exact match
    location =  /Greet[0-9] {
      return 200 "Hello from NGINX 'greet' location";
    }

    # regex match
    location *~ /greet[0-9] {
      return 200 "Hello from NGINX 'greet' regex match";
    }
  }
```

## Variables

Variables are a great way of giving more control over the request in nginx.

## Setting variables

We can set variables and check values according to variables already listed by nginx:

```
http {
  server {
    listen: 80;

    set $weekend 'No';

      if ( $date_local ~ 'Staturday|Sunday' ) {
        set $weekend 'Yes';
      }

      location /is_weekend {
        return 200 $weekend;
      }
  }
}
```

## Args validation

We can for example return a 401 (Unauthorized) for request without a specific arg:

```
server {
 if ($arg_apikey != 1234) {
	return 401;
    }
  location / {

  }
}
```

In this example the user will only be able to go to '/' location if he gives a uri param apikey=1234 otherwise he will be sent a 401 error.

## Redirects

When we use a 30X code for return it means we are redirecting to a uri.
Here is an example for redirecting the logo of our demo/site

```
location /greet {
      return 307 /thumb.png;
    }
```

Notice that when the you get into /greet your uri gets redirected to /greet, changing the resource.

## Rewrites

Rewrites are extremelly powerfull but uses more resources also so they have to be used carefully.

```conf
    rewrite ^/user/\w+ /greet;

    location /greet {
      return 200 "hello user";
    }
```

This will rewrite /user/jon to /greet, matching as a new request.

Still we can do more than one rewrite, but also handling a request to be the last rewrite as we put the "last" keyword at the end of the rewrite.

```conf
    rewrite ^/user/(\w+) /greet/$1 last;
    rewrite ^/greet/john /thumb.png;

    location /greet {
      return 200 "hello user";
    }

    location /greet/john {
      return 200 "Hello john";
    }
```

Rewrites are powerfull as it doesn't change the URI as you can imagine this is amazing for multiple Webservers to be handled by an Nginx proxy.

## Try files

try_files are another directive of nginx to help us serve files.
They can be used in both:

- server context: applying to all server scope
- location context: applying to a specific route scope
  This helps us by letting nginx handle static resources instead of hitting our origin and making our server handle the request for such a resource.
  The syntax is as follows:

```
try_files path1 path2 final;
```

Each path is used as file paths and final a fallback for such request.

## Logging

Nginx provides us two log types:

- Error log: for anything that fail.
- Access log: for everyhing that handles ok.

A typical misuderstanding of logs is to think that 404s will be logged into Error logs. However a properly handled 404 is a perfectly valid response, but nginx will throw a 404 to error when it is not been handled.
For example, in our /sites/demo folder we have our website. If we change that to /sites/demo/other/folder:

```
    root /sites/demo/other/folder;

    location /secure {
      return 200 "Hello user";
    }
```

This will lead to a 404 error, and will be found in our error log.

## Log in location directive

We can also log access and error in a specific location directive, look to example below:

```
    root /sites/demo/other/folder;

    location /secure {
		  access_log /home/nginx/secure.access.log;
      return 200 "Hello user";
    }
```

We can also turn off log access log messages for our locations
so it will optimze our disk resource usage in logging.

```
    root /sites/demo/other/folder;

    location /secure {
		  access_log off;
      return 200 "Hello user";
    }
```

## Setting user troubleshooting

Sometimes when we don't have permission to a specific folder, nginx might throw a 502 error. This usually means that nginx is not allowed to access that path, and very often because the user nginx process is using does not have access.
This can be fixed by using a user with appropriate access or by changing the folder access.

To change the user access we can put a user directive like this:

```
user www-data
```

This means that the nginx process is now using the www-data access for example.

## Worker process

We can spawn more nginx processes by using the directive <strong>worker_processes<strong>, this will tell how many nginx processes it should spawn.
Although, we have to remeber that spawning more processes does not meaning necessarily that nginx will perform better.
When having more processes than cpu core we can think of nginx processes racing against each other more than they should, which will lead to lower performance.

```
worker_processes 2;
```

or

```
worker_processes auto;
```

For the maximum number of cores in your cpu.

## Worker connections

We can also set how many worker connections our server can handle. This can be found more appropriately by using the command:

```
ulimit -n
```

Let's say you got 102, now let's put this into nginx conf:

```
events {
  worker_connections 1024;
}
```

With this we can calculate the number of simultaneos connections our server can handle at once:

num_workers \* worker_connections = total_request_at_once

## Buffers and timeouts

Buffering is the process in which our server get some data and send it into memory(into our bufffer).
In nginx this happens when reading files or when receiving requests, because when nginx receives a requests it will send it to memory so it can handle more requests(async).
We have many directives here so let's list them:

- client_body_buffer_size: 10k; expec
- client_max_body_size: 8m; FOR post, max size of a post request. If this is too large it will respond with a 413.
- client_header_buffer_size: 1k; Max size of reading request headers.
- client_body_timeout 12; Timeout between consecutive read operations.
- client_header_timeout 12; Timeout between consecutive read operations.
- keepalive_timeout 15; Max time to keep before timeout;
- send_timeout 10; Max time for a client accept/receive a response.
- senfile on; When sending a file to a client, read the file from the disk and sends directly to the response.(skip buffering)
- tcp_nopush on; Optimize senfile packets

## Headers and expiration

We can add headers to make static assets available for caching, for faster resquest handling and also avoid hitting the origin of our server every time to serve it.

```
add_header Cache-Control public;
add_header Pragma public;
add_header Vary Accept-Encoding;
expires 60m;
```

- add_header Cache-Control public: Tell in the response the asset can be cached any way.
- add_header Pragma public: older control header for Cache-Control.
- add_header Vary Accept-Encoding: response can vary except for the value of the encoding.
- expires 60m: duration of the cache

## Gzip

Gzip is a common way to help dimishing the size of the request files and sending them to the client. Here a common configuration for zipping files:

```
  gzip on;
  gzip_comp_level 3;
  gzip_types text/css;
  gzip_types text/javascript;
```

Remember you have to add to your request the headers:

```
 "Accept-Encoding: gzip, deflate"
```

So nginx knows you want to do that.

## fastCGI Cache

## HTTP2

HTTP is the new version of the HTTP protocol, its enhancements are:

- It's a binary, not a textual protocol like HTTP, reduces chances of errors
- Compressed Headers, reduces transfer time
- Persistent Connections
- Multiplex Streaming can transmit multiple files through a single connection
- Server Push

Still we need to enable https to work with HTTP2 requests, so you can create a basic self signed protocol and build nginx with http2 modules:

Adde the modules

```
--with_http_ssl_module --with-http_v2_module
```

Create a self signed key with:

```
openssl req -x509 -days 1024 -nodes  -newkey rsa:2048 -keyout /etc/nginx/ssl/self.key -out /etc/nginx/ssl/self.crt
```

Then add the server context should be like this:

```
 server {
   # LISTENING TO HTTPS PORT (443)
    listen 443 ssl http2;
    server_name 192.168.0.24;
    root /sites/demo/;

    index  index.php index.html;
    #LINKING SSL CERTIFICATE AND KEY
    ssl_certificate /etc/nginx/ssl/self.crt;
    ssl_certificate_key /etc/nginx/ssl/self.key;

    location / {
		try_files $uri $uri/ =404;
 	 }

	 location ~\.php$ {
     include fastcgi.conf;
     fastcgi_pass unix:/run/php/php7.2-fpm.sock;
   }
 }
```

Reload nginx and check for caches if you have otherwise you will endup serving old http1 requests.

## Server Push

Server push helps us serving http2 files into a sigle request. To handle it in a ubuntu server we can install the nghttp2-client package.

Install the nghttp2-client

```
apt-get install nghttp2-client
```

set a path to push files:

```
  location = /index.html {
      http2_push /style.css;
      http2_push /thumb.png;
    }
```

This will endup serving three files with a single request.

## HTTP2 Security concerns

Today SSL is already deprecated, there is a new version of the protocol called TSL, and here the instructor gives us a little bit

```conf
#Disable SSL
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

    #Optimise cipher suits
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5;

    #Enable DH Params
    ssl_dhparam /etc/nginx/ssl/dhparam.pem;

    #Enable HSTS
    add_header Strict-Transport-Secury "max-age=31536000" always;

    #SSL sessions
    ssl_Session_cache shared:SSL:40m;
    ssl_session_timeout 4h;
    ssl_session_tickets on;
```

Here we have the steps inside the server context:

1. Disable ssl
2. Set encryption of the servers and it's algorithms
3. enable the DH param
4. Enable HSTS to minimize redirects
5. Session cache

To create a pem file for the ssl_dhparam we have to run the following command:

```
openssl dhparam 2048 -out /etc/nginx/ssl/dhparam.pem
```

Depending on your distribution this might endup creating a file or just printing in your console the RSA key generated.
Whatever happens, check if the file is created and reload nginx.


## Rate Limiting

Rate limitting is an important strategy for limiting brute force hits into our origin.
Here are some directives:

```
 limit_req_zone $request_uri zone=MYZONE:10m rate=60r/m;
```

and to our location
 
```
  limit_req zone=MYZONE burst=5 nodelay;
```

This is defined by:
- limit_req_Zone
- type of uri
- zone=ZONE_NAME:TIMEOUT
- rate=NUM_REQUESTS/r / m|h/s

To test the rate limiting we can use Siege, which can be installed in linux by:

```
sudo apt-get install siege
```

Siege can run many requests tests and give us benchmarks on it by running: 

```
siege -v -r 1 -c 6 https://server_name/thumb.png
```

1. -v : verbose
2. -r : request numbers
3. -c : number of connections

With this we can test our rate limitting strategy and check if its too permisive or too agressive.

## Basic Auth

Here the author generates a simple password to create an "Admin area" based on a file secret password.

Using the apache2-utils package we can use the htpasswd command to create a hash userxPassword credential.

```bash
 htpasswd -c /etc/nginx/.htpasswd user1
```

Now we can set the auth headers to our location we want to secure

```
  auth_basic "Secure Area";
  auth_basic_user_file /etc/nginx/.htpasswd;
```

Whenever the user hits the location a modal will be open to enter credentials.

## Hardening Nginx

1. Avoid iframe injection
2. Avoid cross site requesting

Avoid iframe injection
```
add_header X-Frame-Options "SAMEORIGIN";
```

Avoid cross site requesting
```
add_header X-XSS-Protection "1; mode=block";
```

## Load Balancing

Adding upstreams helps nginx to balance the request load into different origins:

```
upstream php_servers {
    server localhost:10001;    
    server localhost:10002;    
    server localhost:10003;    
  }
```