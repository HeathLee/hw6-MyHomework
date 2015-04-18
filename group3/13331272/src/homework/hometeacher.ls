require! {Issue:'../models/issue'}
require! moment
module.exports = (req, res) !->
	(error, publishs) <-! Issue.find {username : req.user.username}

	return (console.log 'error:', error) if error
	nowtime = (moment new Date()).format 'YYYY-MM-DD HH:mm'
	res.render 'teacher' , user: req.user, publishs: publishs, nowtime: nowtime
