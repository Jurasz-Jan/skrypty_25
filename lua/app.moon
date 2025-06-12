lapis = require "lapis"
Application = lapis.Application

categories = {}
products = {}

class App extends Application
  @get "/categories", (self) ->
    { json: categories }

  @get "/categories/:id", (self) ->
    id = tonumber self.params.id
    for cat in *categories
      if cat.id == id
        return { json: cat }
    return { status: 404, json: { error: "not found" } }

  @post "/categories", (self) ->
    id = #categories + 1
    cat = {
      id: id,
      name: self.params.name
    }
    table.insert categories, cat
    { status: 201, json: cat }

  @put "/categories/:id", (self) ->
    id = tonumber self.params.id
    for cat in *categories
      if cat.id == id
        cat.name = self.params.name if self.params.name
        return { json: cat }
    return { status: 404, json: { error: "not found" } }

  @delete "/categories/:id", (self) ->
    id = tonumber self.params.id
    for i, cat in ipairs categories
      if cat.id == id
        table.remove categories, i
        return { status: 204 }
    return { status: 404, json: { error: "not found" } }

  @get "/products", (self) ->
    { json: products }

  @get "/products/:id", (self) ->
    id = tonumber self.params.id
    for prod in *products
      if prod.id == id
        return { json: prod }
    return { status: 404, json: { error: "not found" } }

  @post "/products", (self) ->
    id = #products + 1
    prod = {
      id: id,
      name: self.params.name,
      price: tonumber(self.params.price)
    }
    table.insert products, prod
    { status: 201, json: prod }

  @put "/products/:id", (self) ->
    id = tonumber self.params.id
    for prod in *products
      if prod.id == id
        prod.name = self.params.name if self.params.name
        prod.price = tonumber(self.params.price) if self.params.price
        return { json: prod }
    return { status: 404, json: { error: "not found" } }

  @delete "/products/:id", (self) ->
    id = tonumber self.params.id
    for i, prod in ipairs products
      if prod.id == id
        table.remove products, i
        return { status: 204 }
    return { status: 404, json: { error: "not found" } }

return App