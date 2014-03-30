path = require 'path'

_ = require 'lodash'
seed = require 'seed-random'
express = require 'express'
module.exports = app = express()

mkpath = -> path.resolve path.join __dirname, arguments...
INDEX_HTML = mkpath 'public', 'index.html'
PUBLIC_DIR = mkpath 'public'
SERVERS = require './servers.json'

respondJSON = (res, code, data) ->
  res.contentType 'application/json'
  res.send code, JSON.stringify data

randInt = (rng, supr) -> Math.floor(rng() * supr)

app.get /^\/api\/v1\/servers$/, (req, res) -> respondJSON res, 200, SERVERS

app.get /^\/api\/v1\/files$/, (req, res) ->
  numServers = SERVERS.servers.length

  url = req.query.url
  rng = seed(url)

  otherIdx = activeIdx = randInt rng, numServers
  otherIdx = randInt rng, numServers until otherIdx != activeIdx

  activeServer = _.extend {}, SERVERS.servers[activeIdx], active: true
  otherServer = SERVERS.servers[otherIdx]

  respondJSON res, 200,
    url: url
    servers: [activeServer, otherServer]

app.use app.router
app.use express.static PUBLIC_DIR

app.use (req, res, next) -> res.sendfile INDEX_HTML

app.listen 9000 if require.main == module
