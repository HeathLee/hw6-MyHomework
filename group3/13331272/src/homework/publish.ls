require! {Issue:'../models/issue'}

module.exports = (req, res) !->
	new-publish = new Issue {
		username : req.user.username
		deadline : req.param 'deadline'
		title : req.param 'title'
		content : req.param 'content'
	}
	new-publish.save (error) !->
		if error
			console.log 'error:', error
			throw error
		else
			console.log 'success'
	res.redirect '/home'

