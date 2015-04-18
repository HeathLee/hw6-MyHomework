require! {Issue:'../models/issue'}

module.exports = (req, res) !->
	(error) <-! Issue.update {title: req.param 'newtitle'}, {$set: {content : req.param 'newcontent'}}
	(error) <-! Issue.update {title: req.param 'newtitle'}, {$set: {deadline : req.param 'newdeadline'}}
	res.redirect '/home'
