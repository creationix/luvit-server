
local extname = require('path').extname

local db = {
  ['.html'] = 'text/html',
  ['.css'] = 'text/css',
  ['.js'] = 'application/js'
}

db.default = 'application/octect-stream'

function db.getMime(path)
  return db[extname(path)] or db.default
end

return db
