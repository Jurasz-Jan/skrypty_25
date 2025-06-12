local lapis = require("lapis")
local Application = lapis.Application

local categories = {}
local products = {}

local app = Application()

app:get("/categories", function(self)
  return { json = categories }
end)

app:get("/categories/:id", function(self)
  local id = tonumber(self.params.id)
  for _, cat in ipairs(categories) do
    if cat.id == id then
      return { json = cat }
    end
  end
  return { status = 404, json = { error = "not found" } }
end)

app:post("/categories", function(self)
  local id = #categories + 1
  local cat = {
    id = id,
    name = self.params.name
  }
  table.insert(categories, cat)
  return { status = 201, json = cat }
end)

app:put("/categories/:id", function(self)
  local id = tonumber(self.params.id)
  for _, cat in ipairs(categories) do
    if cat.id == id then
      if self.params.name then
        cat.name = self.params.name
      end
      return { json = cat }
    end
  end
  return { status = 404, json = { error = "not found" } }
end)

app:delete("/categories/:id", function(self)
  local id = tonumber(self.params.id)
  for i, cat in ipairs(categories) do
    if cat.id == id then
      table.remove(categories, i)
      return { status = 204 }
    end
  end
  return { status = 404, json = { error = "not found" } }
end)

app:get("/products", function(self)
  return { json = products }
end)

app:get("/products/:id", function(self)
  local id = tonumber(self.params.id)
  for _, prod in ipairs(products) do
    if prod.id == id then
      return { json = prod }
    end
  end
  return { status = 404, json = { error = "not found" } }
end)

app:post("/products", function(self)
  local id = #products + 1
  local prod = {
    id = id,
    name = self.params.name,
    price = tonumber(self.params.price)
  }
  table.insert(products, prod)
  return { status = 201, json = prod }
end)

app:put("/products/:id", function(self)
  local id = tonumber(self.params.id)
  for _, prod in ipairs(products) do
    if prod.id == id then
      if self.params.name then
        prod.name = self.params.name
      end
      if self.params.price then
        prod.price = tonumber(self.params.price)
      end
      return { json = prod }
    end
  end
  return { status = 404, json = { error = "not found" } }
end)

app:delete("/products/:id", function(self)
  local id = tonumber(self.params.id)
  for i, prod in ipairs(products) do
    if prod.id == id then
      table.remove(products, i)
      return { status = 204 }
    end
  end
  return { status = 404, json = { error = "not found" } }
end)

return app
