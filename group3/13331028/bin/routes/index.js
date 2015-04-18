(function(){
  var express, howdo, User, StuHw, Hw, router, isAuthenticated;
  express = require('express');
  howdo = require('howdo');
  User = require('../models/user');
  StuHw = require('../models/stuHw');
  Hw = require('../models/hw');
  router = express.Router();
  isAuthenticated = function(req, res, next){
    if (req.isAuthenticated()) {
      return next();
    } else {
      return res.redirect('/');
    }
  };
  module.exports = function(passport){
    router.get('/', function(req, res){
      res.render('index', {
        message: req.flash('message')
      });
    });
    router.post('/login', passport.authenticate('login', {
      successRedirect: '/home',
      failureRedirect: '/',
      failureFlash: true
    }));
    router.get('/signup', function(req, res){
      res.render('register', {
        message: req.flash('message')
      });
    });
    router.post('/signup', passport.authenticate('signup', {
      successRedirect: '/home',
      failureRedirect: '/signup',
      failureFlash: true
    }));
    router.get('/home', isAuthenticated, function(req, res){
      res.render('home', {
        user: req.user
      });
    });
    router.get('/signout', function(req, res){
      req.logout();
      res.redirect('/');
    });
    router.get('/assign', isAuthenticated, function(req, res){
      console.log('you are in assign');
      res.render('assign');
    });
    router.post('/assign', isAuthenticated, function(req, res){
      var request, deadline, newHw;
      request = req.param('request');
      deadline = req.param('deadline');
      if (request === '' || deadline === '') {
        res.redirect('/assign');
      }
      newHw = new Hw({
        tid: req.user._id,
        request: request,
        deadline: deadline
      });
      newHw.save(function(e, product, numAffected){
        if (e) {
          res.send(e.message);
        }
        res.redirect('/home');
      });
    });
    router.get('/show', isAuthenticated, function(req, res){
      var myDate, localTime, hwlist_, findHw, findStuHw, findStusHw, findStuHws;
      console.log(req.user.firstName + ' is viewing all hw');
      myDate = new Date;
      localTime = myDate.toLocaleString();
      hwlist_ = [];
      if (req.user.identity === 'teacher') {
        findHw = function(callback){
          Hw.find({
            tid: req.user._id
          }, function(e, docs){
            var hwlist_;
            if (e) {
              res.send(e.message);
            }
            hwlist_ = docs;
            callback(null, hwlist_);
          });
        };
        findStuHw = function(hw, callback){
          StuHw.find({
            hwid: hw._id
          }, function(e, docs){
            if (e) {
              res.send(e.message);
            }
            hw.stuhwlist = docs;
            callback(null);
          });
        };
        findStusHw = function(hwlist_, callback){
          howdo.each(hwlist_, function(index, hw, next){
            findStuHw(hw, next);
          }).follow(function(err){
            if (err) {
              console.error(err);
            }
            callback(null, hwlist_);
          });
        };
        howdo.task(function(next){
          findHw(next);
        }).task(function(next, hwlist_){
          findStusHw(hwlist_, next);
        }).follow(function(err, hwlist_){
          if (err) {
            console.error(err);
          }
          res.render('show', {
            user: req.user,
            hwlist: hwlist_,
            currentTime: localTime
          });
        });
      }
      if (req.user.identity === 'student') {
        findHw = function(callback){
          Hw.find({}, function(e, docs){
            var hwlist_;
            if (e) {
              res.send(e.message);
            }
            hwlist_ = docs;
            callback(null, hwlist_);
          });
        };
        findStuHw = function(hw, callback){
          StuHw.find({
            hwid: hw._id,
            sid: req.user._id
          }, function(e, docs){
            if (e) {
              res.send(e.message);
            }
            hw.stuhwlist = docs;
            callback(null);
          });
        };
        findStuHws = function(hwlist_, callback){
          howdo.each(hwlist_, function(index, hw, next){
            findStuHw(hw, next);
          }).follow(function(err){
            if (err) {
              console.error(err);
            }
            callback(null, hwlist_);
          });
        };
        howdo.task(function(next){
          findHw(next);
        }).task(function(next, hwlist_){
          findStuHws(hwlist_, next);
        }).follow(function(err, hwlist_){
          if (err) {
            console.error(err);
          }
          res.render('show', {
            user: req.user,
            hwlist: hwlist_,
            currentTime: localTime
          });
        });
      }
    });
    router.get('/change', isAuthenticated, function(req, res){
      var myDate, localTime;
      myDate = new Date;
      localTime = myDate.toLocaleString();
      Hw.find({
        _id: req.param('hwid')
      }, function(e, docs){
        if (e) {
          res.send(e.message);
        }
        res.render('change', {
          hw: docs[0],
          currentTime: localTime
        });
      });
    });
    router.post('/change', isAuthenticated, function(req, res){
      var re, dl;
      re = req.param('request');
      dl = req.param('deadline');
      if (re !== '') {
        Hw.update({
          _id: req.param('hwid')
        }, {
          request: re
        }, function(e, numAffected, raw){
          if (e) {
            res.send(e.message);
          }
          console.log(JSON.stringify(raw));
        });
      }
      if (dl !== '') {
        Hw.update({
          _id: req.param('hwid')
        }, {
          deadline: dl
        }, function(e, numAffected, raw){
          if (e) {
            res.send(e.messagew);
          }
          console.log(JSON.stringify(raw));
        });
      }
      res.redirect('/home');
    });
    router.get('/submit', isAuthenticated, function(req, res){
      Hw.find({
        _id: req.param('hwid')
      }, function(e, docs){
        if (e) {
          res.send(e.message);
        }
        res.render('submit', {
          hw: docs[0]
        });
      });
    });
    router.post('/submit', isAuthenticated, function(req, res){
      var content;
      content = req.param('content');
      if (content !== '') {
        StuHw.find({
          sid: req.user._id,
          hwid: req.param('hwid')
        }, function(e, docs){
          var newStuhw;
          if (e) {
            res.send(e.message);
          }
          if (docs.length !== 0) {
            StuHw.update({
              sid: req.user._id,
              hwid: req.param('hwid')
            }, {
              content: content
            }, function(e, numAffected, raw){
              if (e) {
                res.send(e.message);
              }
              console.log(JSON.stringify(raw));
            });
          } else {
            newStuhw = new StuHw({
              hwid: req.param('hwid'),
              sname: req.user.firstName + ' ' + req.user.lastName,
              sid: req.user._id,
              content: content,
              grade: "(not graded yet)"
            });
            newStuhw.save(function(e, product, numAffected){
              if (e) {
                res.send(e.message);
              }
              console.log('you have saved one hw ' + JSON.stringify(product));
            });
          }
        });
      }
      res.redirect('/home');
    });
    router.get('/mark', isAuthenticated, function(req, res){
      StuHw.find({
        hwid: req.param('hwid', {
          sid: req.param('sid')
        })
      }, function(e, docs){
        if (e) {
          res.send(e.message);
        }
        res.render('mark', {
          stuhw: docs[0]
        });
      });
    });
    return router.post('/mark', isAuthenticated, function(req, res){
      var grade, sid, hwid;
      grade = req.param('grade');
      sid = req.param('sid');
      hwid = req.param('hwid');
      if (grade !== '') {
        StuHw.update({
          sid: sid,
          hwid: hwid
        }, {
          grade: grade
        }, function(e, numAffected, raw){
          if (e) {
            res.send(e.message);
          }
          console.log(JSON.stringify(raw));
        });
      }
      res.redirect('/home');
    });
  };
}).call(this);
