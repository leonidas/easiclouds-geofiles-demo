path = require 'path'
#request = require 'request'
FormData = require 'form-data'
fs = require 'fs'
request = require 'superagent'
EventEmitter = require('events').EventEmitter

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

#quick and ugly communication with accords https://github.com/mikeal/request
app.post '/accords-api', ({body}, res) ->
  data1 = fs.readFileSync 'app_manifest.xml'
  data2 = fs.readFileSync 'deployment_manifest.xml'
  data3 = fs.readFileSync 'agreement.xml'

  #selfsigned sla sertificate at tut :(
  process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

  #stream2 - for reading final response
  stream2 = new EventEmitter
  stream2.buf = ""
  stream2.writable = true
  stream2.write = (chunk) ->
    @buf += chunk

  stream2.end = ->
    console.log "This is the response we needed... Not used for anything"
    console.log @buf

  #stream1 - for reading sla_agreement
  stream1 = new EventEmitter
  stream1.buf = ""
  stream1.writable = true
  stream1.write = (chunk) ->
    @buf += chunk

  stream1.end = ->
    #STEP4 reads sla_agreement and forwards it to brokering

    fs.writeFileSync "sla.xml", @buf
    data4 = fs.readFileSync 'sla.xml'
    console.log "sla was: " + data4

    uri="localhost:8080"
    uri='https://130.230.142.107:8116/broker'

    request.post(uri)
      .attach("filename", data4, filename: 'sla.xml')
      .field('name', 'sla.xml')
      .field('deployment', '0')
      .field('command', 'broker')
      .pipe(stream2)

  callback2 = (res) ->
    #STEP3 posts agreement
    request.post('https://130.230.142.107:8116/parser')
      .attach("filename", data3, filename: 'agreement.xml')
      .field('command', 'parser')
      .pipe(stream1)

  callback1 = (res) ->
    #STEP2 posts deployment_manifest
    request.post('https://130.230.142.107:8116/parser')
      .attach("filename", data2, filename: 'deployment_manifest.xml')
      .field('command', 'parser')
      .end callback2

  #STEP1 posts app_manifest
  request.post('https://130.230.142.107:8116/parser')
    .attach("filename", data1, filename: 'app_manifest.xml')
    .field('command', 'parser')
    .end callback1


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
