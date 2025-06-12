-- config.moon
import config from require "lapis.config"

config "development", ->
  port 8080
  code_cache "off"