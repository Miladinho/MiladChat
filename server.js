var express = require('express')
var ParseDashboard = require('parse-dashboard')
var ParseServer = require('parse-server').ParseServer
require('dotenv').config()

let app = express()

// Allow CORS
app.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*")
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, access-control-allow-origin")
  res.header("Access-Control-Allow-Methods", "GET, POST, DELETE, UPDATE")
  next()
})

app.use('/chat', express.static(__dirname+'/chatServer/static'))

let dashboard = new ParseDashboard({
  apps: [
    {
      'serverURL': process.env.SERVER_URL || 'http://localhost:1337/parse',
      'appId': process.env.APP_ID || 'myAppId',
      'masterKey': process.env.MASTER_KEY || 'myMasterKey',
      'appName': process.env.APP_NAME || 'MyApp'
    }
  ]
})

let api = new ParseServer({
  databaseURI: 'mongodb://localhost:27017/MiladChat', 
  //cloud: '/home/myApp/cloud/main.js', // Absolute path to your Cloud Code
  appId: process.env.APP_ID || 'myAppId',
  masterKey:  process.env.MASTER_KEY || 'myMasterKey', // Keep this key secret!
  fileKey: process.env.FILE_KEY || 'optionalFileKey',
  serverURL: process.env.SERVER_URL || 'http://localhost:1337/parse',
  liveQuery: {
    classNames: ['Chat']
  },
  enableAnonymousUsers: true
});

// Serve the Parse API on the /parse URL prefix
app.use('/parse', api)

// make the Parse Dashboard available at /dashboard
app.use('/dashboard', dashboard)

let httpServer = require('http').createServer(app)
let chat = ParseServer.createLiveQueryServer(httpServer)

httpServer.listen(process.env.PORT || 1337, function() {
  console.log('parse-server-example running on port 1337.');
})