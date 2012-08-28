local http = require 'http'
local pathJoin = require('path').join
local stack = require('stack').stack

local root = pathJoin(__dirname, 'public')

local server = http.createServer(stack(
  function (req, res, pass)
    p(req.method, req.url)
    pass()
  end,
  require('static')(root),
  require('listing')(root)
))

server:listen(8080, function ()
  p(server:address())
end)