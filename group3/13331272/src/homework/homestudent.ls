require! {Issue:'../models/issue'}
require! {Submission:'../models/submission'}
require! {User:'../models/user'}
require! moment

class myhomework
	(publish)!->
		@teacher = publish.username
		@id = publish._id
		@title = publish.title
		@deadline = publish.deadline
		@latest-submission = \none
		@score = \none
		@content = publish.content
		now = moment new Date() .format 'YYYY-MM-DD HH:mm'
		@overdue = now >= @deadline
		@mycontent = \none
module.exports = (req, res) !->
	publish-list = []
	submission-list = []
	(error, publishs) <-! Issue.find!
	publish-list = publishs

	(error, submissions) <-! Submission.find!
	submission-list = submissions


	homeworks = [new myhomework publish for publish in publish-list]
	for homework in homeworks
		for submission in submission-list
			if req.user.lastName+req.user.firstName is submission.username and homework.title is submission.title
				homework.latest-submission = submission.submittime
				homework.score = submission.score
				homework.mycontent = submission.content
	res.render 'student' , user: req.user, homeworks: homeworks
