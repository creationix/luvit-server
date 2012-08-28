
local fs = require 'fs'
local pathJoin = require('path').join
local urlParse = require('url').parse
local getMime = require('./mime').getMime

local floor = require('math').floor
local table = require 'table'

-- For encoding numbers using modified base 64 for compact etags
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

return function (root)
  return function (req, res, pass)
    if not req.uri then
      req.uri = urlParse(req.url)
    end
    local path = pathJoin(root, req.uri.pathname)
    if path:sub(#path) == '/' then
      path = path .. 'index.html'
    end
    fs.open(path, "r", function (err, fd)
      if err then
        if err.code == 'ENOENT' then return
          pass()
        end
        return pass(tostring(err))
      end
      fs.fstat(fd, function (err, stat)
        if err then
          return pass(tostring(err))
        end

        p{headers=req.headers,stat=stat}
        local etag = calcEtag(stat)

        if etag == req.headers['if-none-match'] then
          res:writeHead(304, {
            ['ETag'] = etag
          })
          res:finish()
          return
        end

        local stream = fs.createReadStream(nil, {fd=fd})
        res:writeHead(200, {
          ['Content-Type'] = getMime(path),
          ['Content-Length'] = stat.size,
          ['ETag'] = etag
        })
        stream:pipe(res)
      end)
    end)
  end
end
