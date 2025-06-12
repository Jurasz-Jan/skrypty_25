local Model = require("lapis.db.model").Model

local Category = Model:extend("categories")
Category.primary_key = "id"

return Category
