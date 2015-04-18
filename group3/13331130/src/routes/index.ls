require! {'express', fs: 'fs', Homework: "../models/homework", User: "../models/user"}
router = express.Router! 

is-authenticated = (req, res, next)-> if req.is-authenticated! then next! else res.redirect '/'

module.exports = (passport)->
  router.get '/', (req, res)!-> res.render 'index', message: req.flash 'message'

  router.post '/login', passport.authenticate 'login', {
    success-redirect: '/home', failure-redirect: '/', failure-flash: true
  }

  router.get '/signup', (req, res)!-> res.render 'register', message: req.flash 'message'

  router.post '/signup', passport.authenticate 'signup', {
    success-redirect: '/home', failure-redirect: '/signup', failure-flash: true
  }

  router.get '/home', is-authenticated, (req, res)!->
    Homework.find (err, result)->
      if req.user.role is 'Teacher'
        res.render 'teacher', homework: result
      else
        res.render 'student' homework: result, user: req.user
        

  router.get '/modify/:_id', is-authenticated, (req, res) !->
    (error, homework) <- Homework.find-by-id req.params._id
    return (console.log "Can't find by ID", error ; done error) if error
    
    homework.update 
    res.render 'modify', hw: homework

  router.post '/modify/:_id', is-authenticated, (req, res) !->
    Homework.find-by-id req.params._id, (error, homework) !->
      homework.homeworkName = req.param 'homework-name'
      homework.deadLine = req.param 'deadline'
      homework.save !->
        Homework.find (error, result)->
          res.render 'teacher', homework: result

  router.post '/homework', is-authenticated, (req, res) !->
    new-homework = new Homework {
      homeworkName: req.param 'homework-name'
      teacherID: req.user._id
      deadLine: req.param 'deadline'
    } 
    new-homework.save (error)->
      if error
        console.log "Error in saving  homework: ", error
        throw error
      else
        console.log "Homework appended success"
        res.redirect '/home'

  router.get '/submited/:_id', is-authenticated, (req, res) !->
    Homework.find-by-id req.params._id, (error, homework) !->
      res.render 'submited' hw: homework

  router.get '/signout', (req, res)!-> 
    req.logout!
    res.redirect '/'

  router.post '/upload/:hid', is-authenticated,  (req, res) !->
    (error, homework) <- Homework.find-by-id req.params.hid
    flag = false
    temp-path = req.files.upfile.path.slice 11
    for file, index in homework.submited
      if file.uploaderid.toString! == req.user._id.toString!
        flag = true
        temp = homework.submited[index]
        temp.path = temp-path
        homework.submited.set index, temp
        homework.save (error) !->
          res.redirect '/home'
    if !flag
      homework.submited.push 'uploader': req.user.username, 'uploaderid': req.user._id, 'path': temp-path, 'score': -1
      homework.save (error) !->
        res.redirect '/home'

  router.post '/score/:uid/:hid', is-authenticated, (req, res) !->
    (error, homework) <- Homework.find-by-id req.params.hid
    for file, index in homework.submited
      if file.uploaderid.toString! == req.params.uid.toString!
        temp = homework.submited[index]
        temp.score = req.param 'score'
        homework.submited.set index, temp
        homework.save (error) !->
          res.render 'submited' hw: homework