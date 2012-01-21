module.exports =
  list: (req, res, next) ->
    fs = require 'fs'
    files = fs.readdirSync "./blogs/"
    list = []
    for file, i in files
      filestat = fs.statSync "./blogs/#{file}"
      d = new Date(filestat.mtime)
      list.push [file.slice(0,-3), d]
      #if i is 5 then break
    list.sort (a,b) ->
      b[1].getTime() - a[1].getTime()
    template = require '../templates/list'
    res.send template
      files: list
    
      
  
  article: (req, res, next) ->
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
      
  css: (req, res, next) ->
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
      
    
  repos: (requ, res, next) ->
    https = require 'https'
    opts = 
      host: "api.github.com"
      path: "/users/jaitaiwan/repos"
      method: "GET"
      
    request = https.request opts, (resp) ->
      data = "";
      resp.setEncoding('utf8');
      resp.on 'data', (chunk) ->
        data += chunk;
      
      resp.on 'end', ->
        res.header "Content-type", "application/json"
        res.send data
    request.end();
      
  e404: (req, res, next) ->
    #res.send 'No document here.\n', 404
    console.log 'No document. Requesting basic index\n'
    next()
  