require! ['mongoose']

module.exports = mongoose.model 'submission', {
	id: String,
	username: String,
	submittime: String,
	score: String,
	title: String,
	content: String
}