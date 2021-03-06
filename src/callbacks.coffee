blogList = (index = 0, total = 5) ->
  fs = require 'fs'
  files = fs.readdirSync "./blogs/"
  list = []
  for file, i in files
    filestat = fs.statSync "./blogs/#{file}"
    d = new Date(filestat.mtime)
    list.push [file.slice(0,-3), d] if file[-3..] is ".md"
    if i is total then break
  list.sort (a,b) ->
    b[1].getTime() - a[1].getTime()
  list.splice index, total

categoryList = (max = 5) ->
  try
    categories = require '../posts/categories.coffee'
    categories
  catch err
    console.error err
    {}

category = (name) ->
  try
    categories = categoryList()
    regex = categories[name]
    fs = require 'fs'
    files = fs.readdirSync "./blogs/"
    list = []
    for file, i in files
      filestat = fs.statSync "./blogs/#{file}"
      d = new Date(filestat.mtime)
      list.push [file.slice(0,-3), d] if file[-3..] is ".md" and regex.test(file)
    list.sort (a,b) ->
      b[1].getTime() - a[1].getTime()
    list.splice index, total
  catch err
    console.error err 
    

module.exports =
  list: (req, res, next) ->
    fs = require 'fs'
    md = require('node-markdown').Markdown
    list = blogList()
    content = require('../templates/list')
      files: list
    template = require '../templates/template'
    article = fs.readFileSync "./blogs/#{list[0][0]}.md", 'utf8'
    article = article[0..300]
    article = article.replace /\w+$/, ''
    article = article + "...<hr><a href='/article/#{list[0][0]}'>Read More >></a>"
    res.send template
      Title: "Home"
      Content: md article
      Sidebar: content
      TopNav: categoryList()
    
      
  
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
          TopNav: categoryList()
          Sidebar: require('../templates/list')
            files: blogList()
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
        headers:
          "Accept": "application/vnd.github.v3+json"
          "User-Agent": "jaitaiwan"
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
        headers:
          "Accept": "application/vnd.github.v3+json"
          "User-Agent": "jaitaiwan"
        
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

  categories: (req, res, next) ->
     #TODO categories page
      
  e404: (req, res, next) ->
    #res.send 'No document here.\n', 404
    console.log 'No document. Requesting basic index\n'
    next()
  
