server = require('express').createServer()

try
  routes = require './router'
  server[route.method] route.matches,route.callback for route in routes
catch err
  console.error err

server.listen require('./config').port; 