require! ['./login', './signup', '../models/user']

module.exports = (passport)-> 
  passport.serialize-user (user, done)->
    console.log 'serialize user: ', user
    done null, user._id

  passport.deserialize-user (id, done)-> user.find-by-id id, (error, user)!->
    console.log 'deserialize user: ', user
    done error, user

  login passport
  signup passport
