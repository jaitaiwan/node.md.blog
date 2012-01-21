routes = [
  {
    method: "get"
    matches: "/article/:document"
    callback: (req, res) ->
      fs = require 'fs'
      md = require('node-markdown').Markdown
      try
        filename = "./blogs/#{req.params.document}.md"
        filestat = fs.statSync filename
        if filestat.isFile()
          document = fs.readFileSync filename, 'utf8'
          template = require '../templates/blog'
          res.send template
            Title: req.params.document
            Post: md(document)
      catch err
        res.send "Page cannot be found", 404
        console.error "Client requested '" + req.params.document + "' which cannot be found."
  }
  
  {
    method: "get"
    matches: "/media/css/:document"
    callback: (req, res) ->
      fs = require 'fs'
      filename = "./templates/#{req.params.document}.styl"
      try
        stat = fs.statSync filename
      catch err
        console.log err
        res.send "File not found.\n",404
        0
      if stat?.isFile()
        res.header "Content-type", "text/css"
        res.send require "../templates/#{req.params.document}"
      else
        res.send "File not found.\n",404
  }
  
  {
    method: "get"
    matches: '/list'
    callback: (req, res) ->
      fs = require 'fs'
      files = fs.readdirSync("./blogs/")
      res.write "#{((file.charAt(0).toUpperCase() + file.slice(1, -3)).split('_')).join(' ')}\n" for file in files
      res.end()
  }
  
  {
    method: "get"
    matches: "/*:anything"
    callback: (req, res) ->
      res.send 'No document here.\n', 404
      console.log 'No document. Requesting basic index\n'
  }
]

module.exports = routes