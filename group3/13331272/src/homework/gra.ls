require! {Submission:'../models/submission'}

module.exports = (req, res) !->
	score = req.param 'grade'
	id = req.param 'id'
	(err) <- Submission.update {_id: id}, {$set: {score : score}}
    
	res.redirect "/grade/?title=#{req.param 'title1'}"