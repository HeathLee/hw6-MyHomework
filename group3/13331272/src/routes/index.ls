require! ['express']
router = express.Router! 

is-authenticated = (req, res, next)-> if req.is-authenticated! then next! else res.redirect '/'

module.exports = (passport, homework)->
  router.get '/', (req, res)!-> res.render 'index', message: req.flash 'message'

  router.post '/login', passport.authenticate 'login', {
    success-redirect: '/home', failure-redirect: '/', failure-flash: true
  }

  router.get '/signup', (req, res)!-> res.render 'register', message: req.flash 'message'

  router.post '/signup', passport.authenticate 'signup', {
    success-redirect: '/home', failure-redirect: '/signup', failure-flash: true
  }

  router.get '/home', is-authenticated, (req, res)!-> 
    if req.user.role is 'teacher'
      homework.teacher req, res
    else if req.user.role is 'student'
      homework.student req, res

  router.get '/signout', (req, res)!-> 
    req.logout!
    res.redirect '/'
  router.post '/publish', is-authenticated, (req, res)!->
    homework.publish req, res

  router.post '/submit', is-authenticated, (req, res)!->
    homework.submit req, res

  router.get '/grade', is-authenticated, (req, res)!->
    homework.grade req, res
  router.post '/grade', is-authenticated, (req, res)!->
    homework.gra req, res
  router.post '/edit', is-authenticated, (req, res)!->
    homework.edit req, res

