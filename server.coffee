path = require 'path'

express = require 'express'
module.exports = app = express()

mkpath = -> path.resolve path.join __dirname, arguments...
INDEX_HTML = mkpath 'public', 'index.html'
PUBLIC_DIR = mkpath 'public'
SERVERS = JSON.stringify require './servers.json'

respondJSON = (res, code, data) ->
  res.contentType 'application/json'
  res.send code, JSON.stringify data

app.get /^\/api\/v1\/servers$/, (req, res) -> respondJSON res, 200, SERVERS

app.get /^\/api\/v1\/files$/, (req, res) ->
  url = req.query.url
  respondJSON res, 200,
    url: url
    servers: SERVERS

app.use app.router
app.use express.static(PUBLIC_DIR, maxAge: 24*60*60*1000)
app.use (req, res, next) -> res.sendfile INDEX_HTML

app.listen 9000 if require.main == module
