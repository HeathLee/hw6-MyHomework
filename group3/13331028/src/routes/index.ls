require! {'express', howdo: 'howdo', User: '../models/user', StuHw: '../models/stuHw', Hw: '../models/hw'}
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

  router.get '/home', is-authenticated, (req, res)!-> res.render 'home', user: req.user

  router.get '/signout', (req, res)!-> 
    req.logout!
    res.redirect '/'

# ---new code---
  # page: assign
  router.get '/assign', is-authenticated, (req, res)!->
    console.log 'you are in assign'
    res.render 'assign'
  
  router.post '/assign', is-authenticated, (req, res)!->
    request = req.param 'request'
    deadline = req.param 'deadline'

    if request is '' or deadline is '' then res.redirect '/assign'

    new-hw = new Hw {
      tid      : req.user._id
      request  : request
      # check the style of deadline
      deadline : deadline
    }
    new-hw.save (e, product, numAffected)!->
      if e then res.send e.message
      res.redirect '/home'

  # page: show
  router.get '/show', is-authenticated, (req, res)!->
    console.log req.user.firstName + ' is viewing all hw'
    
    # 客户端的时间
    myDate = new Date
    localTime = myDate.toLocaleString()

    hwlist_ = []
    if req.user.identity is 'teacher'
      findHw = (callback)!->
        Hw.find {tid: req.user._id} (e, docs)!->
          if e then res.send e.message
          hwlist_ = docs
          callback null, hwlist_

      findStuHw = (hw, callback)!->
        StuHw.find {hwid: hw._id} (e, docs)!->
          if e then res.send e.message
          hw.stuhwlist = docs
          callback null

      findStusHw = (hwlist_, callback)!->
          howdo
            .each hwlist_, (index, hw, next)!->
              findStuHw hw, next
            .follow (err)!->
              if err then console.error err
              callback null, hwlist_
      
      howdo
        .task (next)!->
          findHw next
        .task (next, hwlist_)!->
          findStusHw hwlist_, next
        .follow (err, hwlist_)!->
          if err then console.error err
          res.render 'show', {user: req.user, hwlist: hwlist_, currentTime: localTime}

    if req.user.identity is 'student'
      findHw = (callback)!->
        Hw.find {} (e, docs)!->
          if e then res.send e.message
          hwlist_ = docs
          callback null, hwlist_

      findStuHw = (hw, callback)!->
        StuHw.find {hwid: hw._id, sid: req.user._id} (e, docs)!->
          if e then res.send e.message
          hw.stuhwlist = docs
          callback null

      findStuHws = (hwlist_, callback)!->
          howdo
            .each hwlist_, (index, hw, next)!->
              findStuHw hw, next
            .follow (err)!->
              if err then console.error err
              callback null, hwlist_
      
      howdo
        .task (next)!->
          findHw next
        .task (next, hwlist_)!->
          findStuHws hwlist_, next
        .follow (err, hwlist_)!->
          if err then console.error err
          res.render 'show', {user: req.user, hwlist: hwlist_, currentTime: localTime}

  # page: change
  router.get '/change', is-authenticated, (req, res)!->
    # 客户端的时间
    myDate = new Date
    localTime = myDate.toLocaleString()

    Hw.find {_id: req.param 'hwid'} (e, docs)!->
      if e then res.send e.message
      res.render 'change', {hw: docs[0], currentTime: localTime}

  router.post '/change', is-authenticated, (req, res)!->
    re = req.param 'request'
    dl = req.param 'deadline'
    if re isnt '' then Hw.update {_id: req.param 'hwid'} {request: re} (e, numAffected, raw)!->
      if e then res.send e.message
      console.log JSON.stringify raw
    if dl isnt '' then Hw.update {_id: req.param 'hwid'} {deadline: dl} (e, numAffected, raw)!->
      if e then res.send e.messagew
      console.log JSON.stringify raw
    res.redirect '/home'

  # page: submit
  router.get '/submit', is-authenticated, (req, res)!->
    Hw.find {_id: req.param 'hwid'} (e, docs)!->
      if e then res.send e.message
      res.render 'submit', {hw: docs[0]}

  router.post '/submit', is-authenticated, (req, res)!->
    content = req.param 'content'
    if content isnt ''
      StuHw.find {sid: req.user._id, hwid: req.param 'hwid'} (e, docs)!->
        if e then res.send e.message
        if docs.length != 0
          StuHw.update {sid: req.user._id, hwid: req.param 'hwid'} {content: content} (e, numAffected, raw)!->
            if e then res.send e.message
            console.log JSON.stringify raw
        else
          new-stuhw = new StuHw {
            hwid     : req.param 'hwid'
            sname    : req.user.firstName + ' ' + req.user.lastName
            sid      : req.user._id
            content  : content
            grade    : "(not graded yet)"
          }
          new-stuhw.save (e, product, numAffected)!->
            if e then res.send e.message
            console.log 'you have saved one hw ' + JSON.stringify(product)
    res.redirect '/home'

  # page: mark
  router.get '/mark', is-authenticated, (req, res)!->
    StuHw.find {hwid: req.param 'hwid', sid: req.param 'sid'} (e, docs)!->
      if e then res.send e.message
      res.render 'mark', {stuhw: docs[0]}

  router.post '/mark', is-authenticated, (req, res)!->
    grade = req.param 'grade'
    sid = req.param 'sid'
    hwid = req.param 'hwid'
    if grade isnt '' then StuHw.update {sid: sid, hwid: hwid} {grade: grade} (e, numAffected, raw)!->
      if e then res.send e.message
      console.log JSON.stringify raw
    res.redirect '/home'