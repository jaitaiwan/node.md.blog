module.exports =
  list: (req, res, next) ->
    fs = require 'fs'
    md = require('node-markdown').Markdown
    files = fs.readdirSync "./blogs/"
    list = []
    for file, i in files
      filestat = fs.statSync "./blogs/#{file}"
      d = new Date(filestat.mtime)
      list.push [file.slice(0,-3), d] if file[-3..] is ".md"
      #if i is 5 then break
    list.sort (a,b) ->
      b[1].getTime() - a[1].getTime()
    content = require('../templates/list')
      files: list
    template = require '../templates/template'
    res.send template
      Title: "Home"
      Content: md fs.readFileSync "./blogs/#{list[0][0]}.md", 'utf8'
      Sidebar: content
    
      
  
  article: (req, res, next) ->
    fs = require 'fs'
    md = require('node-markdown').Markdown
    try
      filename = "./blogs/#{req.params.document}.md"
      filestat = fs.statSync filename
      if filestat.isFile()
        document = fs.readFileSync filename, 'utf8'
        title = "#{((req.params.document.charAt(0).toUpperCase() + req.params.document[1..]).split('_')).join(' ')}"
        template = require '../templates/template'
        content = require('../templates/blog')
          Title: title
          Post: md(document)
        res.send template
          Title: title
          Content: content
    catch err
      res.send "Page cannot be found", 404
      console.error "Client requested '" + req.params.document + "' which cannot be found.", err
      
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
    fs = require 'fs'
    saveToCache = (data) ->
      try
        fs.readdirSync "./cache/"
      catch err
        fs.mkdirSync "./cache"
      fs.writeFileSync './cache/repos.json', data
    
    cachefile = './cache/repos.json'
    try
      stat = fs.statSync cachefile
    catch err
      
    now = new Date()
    now = now.getTime()
    if not stat? or not stat?.isFile() or ((now - stat?.mtime.getTime()) > 3600000)
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
          saveToCache data
          res.header "Content-type", "application/json"
          res.send data
      request.end();
    else
      res.header "Content-type", "application/json"
      res.send fs.readFileSync cachefile, 'utf8'
    
  profile: (req,res) ->
    fs = require 'fs'
    saveToCache = (data) ->
      try
        fs.readdirSync "./cache/"
      catch err
        fs.mkdirSync "./cache"
      fs.writeFileSync './cache/profile.json', data
      
    cachefile = './cache/profile.json'
    try
      stat = fs.statSync cachefile
    catch err
      
    now = new Date()
    now = now.getTime()
    if not stat? or not stat?.isFile() or ((now - stat?.mtime.getTime()) > 3600000)
      https = require 'https'
      opts = 
        host: "api.github.com"
        path: "/users/jaitaiwan"
        method: "GET"
        
      request = https.request opts, (resp) ->
        data = "";
        resp.setEncoding('utf8');
        resp.on 'data', (chunk) ->
          data += chunk;
        
        resp.on 'end', ->
          saveToCache data
          res.header "Content-type", "application/json"
          res.send data
      request.end()
    else
      res.header "Content-type", "application/json"
      res.send fs.readFileSync cachefile, 'utf8'
      
  e404: (req, res, next) ->
    #res.send 'No document here.\n', 404
    console.log 'No document. Requesting basic index\n'
    next()
  