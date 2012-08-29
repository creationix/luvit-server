local pathJoin = require('path').join
local root = pathJoin(__dirname, 'public')
local createServer = require('web').createServer

-- Define a simple custom app
local function app(req, res)
  if req.url.path == "/greet" then
    return res(200, {
      ["Content-Type"] = "text/plain",
      ["Content-Length"] = 12
    }, "Hello World\n")
  end
  res(404, {
    ["Content-Type"] = "text/plain",
    ["Content-Length"] = 10
  }, "Not Found\n")
end

-- Allow directory listing
app = require('listing')(app, __dirname .. "/public")
-- Serve static files
app = require('static')(app, __dirname .. "/public")
-- Log all requests
app = require('log')(app)

local server = createServer("0.0.0.0", 8080, app)
p("http server listening on ", server:getsockname())

--[[
local server = http.createServer(stack(
  function (req, res, pass)
    pass()
  end,
  require('static')(root),
  require('listing')(root)
))

server:listen(8080, function ()
  p(server:address())
end)
]]