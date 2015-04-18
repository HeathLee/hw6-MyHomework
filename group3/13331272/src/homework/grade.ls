require! {Submission:'../models/submission'}

module.exports = (req, res) !->
	(error, submissions) <-! Submission.find {title : req.param 'title'}
	return (console.log 'error:', error) if error
	res.render 'grade' , user: req.user, submissions: submissions,  title: req.param('title')