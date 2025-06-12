local Model = require("lapis.db.model").Model

local Product = Model:extend("products")
Product.primary_key = "id"

return Product
