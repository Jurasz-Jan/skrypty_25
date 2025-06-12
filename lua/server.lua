-- server.lua
local serve = require("lapis.cmd.actions").serve
local app = require("app")
serve(app, "development")
