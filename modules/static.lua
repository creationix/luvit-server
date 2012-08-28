
local fs = require 'fs'
local pathJoin = require('path').join
local urlParse = require('url').parse
local getMime = require('./mime').getMime

return function (root)
  return function (req, res, pass)
    local uri = urlParse(req.url)
    local path = pathJoin(root, uri.pathname)
    if path:sub(#path) == '/' then
      path = path .. 'index.html'
    end
    fs.readFile(path, function (err, contents)
      if err then
        if err.code == 'ENOENT' then return
          pass()
        end
        return pass(tostring(err))
      end
      res:writeHead(200, {
        ['Content-Type'] = getMime(path),
        ['Content-Length'] = #contents
      })
      res:finish(contents)
    end)
  end
end
