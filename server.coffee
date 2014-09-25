path = require 'path'
request = require 'request'

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

app.post '/test', ({body}, res) ->
  process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"
  options =
    uri: 'https://130.230.142.107:8116/'
    rejectUnhauthorized : false

  request options, (error, response, body) ->
    console.log "testi"
    console.log error
    console.log response
    if !error && response.statusCode == 200
      console.log body

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
