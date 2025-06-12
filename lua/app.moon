import Application from require "lapis"

-- in-memory stores
categories = {}
products = {}

class App extends Application
  -- list categories
  @get "/categories" =>
    { json: categories }

  -- get single category
  @get "/categories/:id" =>
    id = tonumber @params.id
    for cat in *categories
      if cat.id == id
        return { json: cat }
    return { status: 404, json: { error: "not found" } }

  -- create category
  @post "/categories" =>
    id = #categories + 1
    cat = {
      id: id,
      name: @params.name
    }
    table.insert categories, cat
    { status: 201, json: cat }

  -- update category
  @put "/categories/:id" =>
    id = tonumber @params.id
    for cat in *categories
      if cat.id == id
        cat.name = @params.name if @params.name
        return { json: cat }
    return { status: 404, json: { error: "not found" } }

  -- delete category
  @delete "/categories/:id" =>
    id = tonumber @params.id
    for i, cat in ipairs categories
      if cat.id == id
        table.remove categories, i
        return { status: 204 }
    return { status: 404, json: { error: "not found" } }

  -- list products
  @get "/products" =>
    { json: products }

  -- get single product
  @get "/products/:id" =>
    id = tonumber @params.id
    for prod in *products
      if prod.id == id
        return { json: prod }
    return { status: 404, json: { error: "not found" } }

  -- create product
  @post "/products" =>
    id = #products + 1
    prod = {
      id: id,
      name: @params.name,
      price: tonumber(@params.price)
    }
    table.insert products, prod
    { status: 201, json: prod }

  -- update product
  @put "/products/:id" =>
    id = tonumber @params.id
    for prod in *products
      if prod.id == id
        prod.name = @params.name if @params.name
        prod.price = tonumber(@params.price) if @params.price
        return { json: prod }
    return { status: 404, json: { error: "not found" } }

  -- delete product
  @delete "/products/:id" =>
    id = tonumber @params.id
    for i, prod in ipairs products
      if prod.id == id
        table.remove products, i
        return { status: 204 }
    return { status: 404, json: { error: "not found" } }

return App
