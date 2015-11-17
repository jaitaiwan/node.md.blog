express = require 'express'
app = express()
app.use "/images", express.static "./templates/images"
app.use "/scripts", express.static "./templates/scripts"

try
  routes = require './router'
  app[route.method] route.matches,route.callback for route in routes
catch err
  console.error err

app.listen require('./config').port