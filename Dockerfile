FROM nginx:alpine

RUN apk add --no-cache \
        git \
        libxml2-dev \
        libxslt-dev \
        yajl-dev \
        lmdb-dev \
        libmaxminddb-dev \
        geoip-dev \
        apache2-dev \
        curl \
        gcc \
        g++ \
        make \
        automake \
        autoconf \
        libtool \
        pcre-dev \
        zlib-dev \
        linux-headers \
        openssl-dev && \
    git clone --depth 1 -b v3/master --single-branch https://github.com/owasp-modsecurity/ModSecurity /opt/ModSecurity && \
    cd /opt/ModSecurity && \
    git submodule init && \
    git submodule update && \
    ./build.sh && \
    ./configure && \
    make && \
    make install && \
    git clone --depth 1 https://github.com/owasp-modsecurity/ModSecurity-nginx /opt/ModSecurity-nginx && \
    cd /opt/ModSecurity-nginx && \
    cd src && \
    wget http://nginx.org/download/nginx-$(nginx -v 2>&1 | awk -F/ '{print $2}').tar.gz && \
    tar zxf nginx-*.tar.gz && \
    cd nginx-* && \
    ./configure --with-compat --with-openssl=/usr/include/openssl/ --add-dynamic-module=/opt/ModSecurity-nginx && \
    make modules && \
    cp objs/ngx_http_modsecurity_module.so /etc/nginx/modules && \
    apk del gcc g++ make automake autoconf libtool && \
    rm -rf /var/cache/apk/* /usr/src/* /opt/*

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
