-- config.lua
local config = require("lapis.config").config

config("development", {
  port = 8080,
  code_cache = "off"
})
