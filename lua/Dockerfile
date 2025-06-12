FROM openresty/openresty:alpine-fat

RUN apk add --no-cache git build-base openssl-dev

RUN luarocks install moonscript && luarocks install lapis

WORKDIR /app
COPY . .

EXPOSE 8080
CMD ["lapis", "server", "development"]

