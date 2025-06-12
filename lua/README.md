# MoonScript REST API

This folder contains a simple REST API written in MoonScript using the [Lapis](https://leafo.net/lapis/) framework.

## Requirements

These instructions assume a Windows environment.

1. Install [Lua](https://luabinaries.sourceforge.net/) (5.1 or LuaJIT) and [LuaRocks](https://luarocks.org/).
2. From a command prompt install required rocks:

```bash
luarocks install lapis
luarocks install moonscript
```

## Running

Navigate to the repository directory and execute:

```bash
moon lua/server.moon
```

The server will start on `http://localhost:8080` by default. Endpoints for
categories and products support standard CRUD operations and return JSON
responses.

## Docker

You can also run the API using Docker. From the `lua` directory run:

```bash
docker-compose up --build
```

The service will be available at `http://localhost:8080`.
