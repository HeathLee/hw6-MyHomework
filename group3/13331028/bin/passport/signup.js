(function(){
  var User, bcryptNodejs, passportLocal, LocalStrategy, hash;
  User = require('../models/user');
  bcryptNodejs = require('bcrypt-nodejs');
  passportLocal = require('passport-local');
  LocalStrategy = passportLocal.Strategy;
  hash = function(password){
    return bcryptNodejs.hashSync(password, bcryptNodejs.genSaltSync(10), null);
  };
  module.exports = function(passport){
    passport.use('signup', new LocalStrategy({
      passReqToCallback: true
    }, function(req, username, password, done){
      User.findOne({
        username: username
      }, function(error, user){
        var msg, newUser;
        if (error) {
          return console.log("Error in signup: ", error), done(error);
        }
        if (user) {
          console.log(msg = "User: " + username + " already exists");
          return done(null, false, req.flash('message', msg));
        } else {
          newUser = new User({
            username: username,
            password: hash(password),
            email: req.param('email'),
            firstName: req.param('firstName'),
            lastName: req.param('lastName'),
            identity: req.param('identity')
          });
          return newUser.save(function(error){
            if (error) {
              console.log("Error in saving user: ", error);
              throw error;
            } else {
              console.log("User registration success");
              return done(null, newUser);
            }
          });
        }
      });
    }));
  };
}).call(this);
