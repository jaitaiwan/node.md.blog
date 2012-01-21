express = require 'express'
server = express.createServer()
server.use "/images", express.static "./templates/images"

try
  routes = require './router'
  server[route.method] route.matches,route.callback for route in routes
catch err
  console.error err

server.listen require('./config').port; 