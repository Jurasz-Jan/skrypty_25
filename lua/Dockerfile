FROM openresty/openresty:alpine

# install LuaRocks and build tools
RUN apk add --no-cache lua5.1 lua5.1-dev luarocks git build-base

# install dependencies
RUN luarocks install moonscript && luarocks install lapis

WORKDIR /app
COPY . .

EXPOSE 8080
CMD ["moon", "server.moon"]
