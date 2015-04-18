require! {Issue:'../models/issue'}

module.exports = (req, res) !->
	(error) <-! Issue.update {title: req.param 'newtitle'}, {$set: {content : req.param 'newcontent'}}
	res.redirect '/home'
