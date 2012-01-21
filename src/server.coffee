server = require('express').createServer()
fs = require 'fs'
md = require('node-markdown').Markdown

server.get '/:document', (req, res) ->
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
    res.send("Page cannot be found",404);
  
server.get '/', (req, res) ->
  res.send('No requested document.');
  console.log('Requesting basic index');


server.listen 8000; 