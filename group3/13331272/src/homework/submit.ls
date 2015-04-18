require! {Submission:'../models/submission'}
require! moment
module.exports = (req, res) !->
	#<-! Submission.remove {username: req.user.username, title:req.param 'title'}
	new-submission = new Submission {
		username : req.user.username
		title : req.param 'title'
		content : req.param 'content'
		score: 'none'
		submittime: (moment new Date()).format 'YYYY-MM-DD HH:mm'
	}
	
	new-submission.save (error) !->
		if error
			console.log 'error:', error
			throw error
		else
			console.log 'success'
	res.redirect '/home'