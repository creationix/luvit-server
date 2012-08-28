
local extname = require('path').extname

local db = {
  ['.png'] = 'image/png',
  ['.gif'] = 'image/gif',
  ['.jpg'] = 'image/jpeg',
  ['.jpeg'] = 'image/jpeg',
  ['.html'] = 'text/html',
  ['.css'] = 'text/css',
  ['.markdown'] = 'text/x-markdown',
  ['.md'] = 'text/x-markdown',
  ['.lua'] = 'text/x-lua',
  ['.luac'] = 'application/x-lua-bytecode',
  ['.js'] = 'application/javascript',
  ['.json'] = 'application/json',
  ['.msgpack'] = 'application/x-msgpack',
  ['.gz'] = 'application/x-gzip',
  ['.gzip'] = 'application/x-gzip',
  ['.zip'] = 'application/zip'
}

db.default = 'application/octect-stream'

function db.getMime(path)
  return db[extname(path)] or db.default
end

return db
