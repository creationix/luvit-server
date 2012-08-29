
local fs = require 'fs'
local pathJoin = require('path').join
local urlParse = require('url').parse
local table = require 'table'

return function (app, root)
  return function (req, res)
    local path = req.url.path
    if path:sub(#path) ~= '/' then
      return app(req, res)
    end
    path = path:sub(1, #path - 1)
    path = pathJoin(root, req.url.path)
    fs.readdir(path, function (err, files)
      p(path, err, files)
      if err then
        if err.code == 'ENOENT' then
          return app(req, res)
        end
        return res(500, {}, tostring(err))
      end
      local html = {
        '<!doctype html>',
        '<html>',
        '<head>',
          '<title>' .. req.url.path .. '</title>',
        '</head>',
        '<body>',
          '<h1>' .. req.url.path .. '</h1>',
          '<ul>',
      }
      for i, file in ipairs(files) do
        html[#html + 1] =
            '<li><a href="' .. file .. '">' .. file .. '</a></li>'
      end
      html[#html + 1] = '</ul></body></html>'
      html = table.concat(html, '')
      res(200, {
          ["Content-Type"] = "text/html",
          ["Content-Length"] = #html
      }, html)
    end)
  end
end