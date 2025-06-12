FROM openresty/openresty:alpine-fat

RUN apk add --no-cache git build-base openssl-dev

RUN luarocks install lapis

WORKDIR /app
COPY . .
RUN mkdir -p /etc/nginx \
    && cp /usr/local/openresty/nginx/conf/mime.types /etc/nginx/mime.types \
    && cp /usr/local/openresty/nginx/conf/mime.types /app/mime.types

EXPOSE 8080
CMD ["lapis", "server", "development"]

