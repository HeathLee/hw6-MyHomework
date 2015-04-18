(function(){
  var express, http, path, cookieParser, bodyParser, mongoose, passport, expressSession, db, logger, flash, favicon, app, server, initPassport, routes, exports;
  express = require('express');
  http = require('http');
  path = require('path');
  cookieParser = require('cookie-parser');
  bodyParser = require('body-parser');
  mongoose = require('mongoose');
  passport = require('passport');
  expressSession = require('express-session');
  db = require('./db');
  logger = require('morgan');
  flash = require('connect-flash');
  favicon = require('static-favicon');
  mongoose.connect(db.url);
  app = express();
  server = http.createServer(app);
  app.set('views', path.join(__dirname, 'views'));
  app.set('view engine', 'jade');
  app.use(favicon());
  app.use(logger('dev'));
  app.use(bodyParser.json());
  app.use(bodyParser.urlencoded());
  app.use(cookieParser());
  app.use(express['static'](path.join(__dirname, 'public')));
  app.use(expressSession({
    secret: 'mySecretKey'
  }));
  app.use(passport.initialize());
  app.use(passport.session());
  app.use(flash());
  initPassport = require('./passport/init');
  initPassport(passport);
  routes = require('./routes/index')(passport);
  app.use('/', routes);
  app.use(function(req, res, next){
    var err;
    err = new Error('Not Found');
    err.status = 404;
    return next(err);
  });
  if (app.get('env') === 'development') {
    app.use(function(err, req, res, next){
      res.status(err.status || 500);
      return res.render('error', {
        message: err.message,
        error: err
      });
    });
  }
  exports = module.exports = server;
  exports.use = function(){
    return app.use.apply(app, arguments);
  };
}).call(this);
