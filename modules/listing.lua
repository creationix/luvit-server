
local fs = require 'fs'
local pathJoin = require('path').join
local urlParse = require('url').parse
local table = require 'table'

return function (root)
  return function (req, res, pass)
    local uri = urlParse(req.url)
    local path = pathJoin(root, uri.pathname)
    if path:sub(#path) ~= '/' then
      return pass()
    end
    fs.readdir(path, function (err, files)
      if err then
        if err.code == 'ENOENT' then
          return pass()
        end
        return pass(tostring(err))
      end
      local html = {
        '<!doctype html>',
        '<html>',
        '<head>',
          '<title>' .. uri.pathname .. '</title>',
        '</head>',
        '<body>',
          '<h1>' .. uri.pathname .. '</h1>',
          '<ul>',
      }
      for i, file in ipairs(files) do
        html[#html + 1] = 
            '<li><a href="' .. file .. '">' .. file .. '</a></li>'
      end
      html[#html + 1] = '</ul></body></html>'
      res:finish(table.concat(html, ''))
    end)
  end
end