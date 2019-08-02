# Nginx Fundamentals

Nginx was created to have a better performance than apache server. At the time apache handled the basic idea of a single request at a time, in other words, synchronously. 

Nginx process was designed to handle request asynchronously. It can handle multiple requests at once instead of waiting a first request to handle a second one.
This is called concurrent request.

# Install the source of nginx

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

# Usage of this repo

Create a /site folder in your root and move the /demo folder into it.


# About Location 

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
# Variables
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

# Redirects
When we use a 30X code for return it means we are redirecting to a uri. 
Here is an example for redirecting the logo of our demo/site

```
location /greet {
      return 307 /thumb.png;
    }
```
Notice that when the you get into /greet your uri gets redirected to /greet, changing the resource.

# Rewrites
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


