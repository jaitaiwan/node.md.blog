callbacks = require './callbacks'

routes = [
  {
    method: "get"
    matches: "/article/:document"
    callback: callbacks.article
  }
  
  {
    method: "get"
    matches: "/media/css/:document"
    callback: callbacks.css
  }
  
  {
    method: "get"
    matches: '/list'
    callback: callbacks.list
  }
  
  {
    method: "get"
    matches: "/projects"
    callback: callbacks.repos
  }
  
  {
    method: "get"
    matches: "/github"
    callback: callbacks.profile
  }
  
  {
    method: "get"
    matches: "/*:anything"
    callback: callbacks.e404
  }
  
  {
    method: "get"
    matches: "/"
    callback: callbacks.list
  }
]

module.exports = routes