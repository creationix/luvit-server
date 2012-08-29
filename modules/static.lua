
local fs = require 'fs'
local pathJoin = require('path').join
local urlParse = require('url').parse
local getType = require('mime').getType

local floor = require('math').floor
local table = require 'table'

-- For encoding numbers using bases up to 64
local digits = {
  "0", "1", "2", "3", "4", "5", "6", "7",
  "8", "9", "A", "B", "C", "D", "E", "F",
  "G", "H", "I", "J", "K", "L", "M", "N",
  "O", "P", "Q", "R", "S", "T", "U", "V",
  "W", "X", "Y", "Z", "a", "b", "c", "d",
  "e", "f", "g", "h", "i", "j", "k", "l",
  "m", "n", "o", "p", "q", "r", "s", "t",
  "u", "v", "w", "x", "y", "z", "_", "$"
}
local function numToBase(num, base)
  local parts = {}
  repeat
    table.insert(parts, digits[(num % base) + 1])
    num = floor(num / base)
  until num == 0
  return table.concat(parts)
end

local function calcEtag(stat)
  return (not stat.is_file and 'W/' or '') ..
         '"' .. numToBase(stat.ino or 0, 64) ..
         '-' .. numToBase(stat.size, 64) ..
         '-' .. numToBase(stat.mtime, 64) .. '"'
end

return function (app, root)
  return function (req, res)
    local path = pathJoin(root, req.url.path)
    if path:sub(#path) == '/' then
      path = path .. 'index.html'
    end
    fs.open(path, "r", function (err, fd)
      if err then
        if err.code == 'ENOENT' then
          return app(req, res)
        end
        return res(500, {}, tostring(err))
      end
      fs.fstat(fd, function (err, stat)
        if err then
          return res(500, {}, tostring(err))
        end

        local etag = calcEtag(stat)

        if etag == req.headers['if-none-match'] then
          return res(304, {
            ['ETag'] = etag
          })
        end

        local stream = fs.createReadStream(nil, {fd=fd})
        res(200, {
          ['Content-Type'] = getType(path),
          ['Content-Length'] = stat.size,
          ['ETag'] = etag
        }, stream)
      end)
    end)
  end
end
