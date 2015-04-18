require! ['mongoose']

module.exports = mongoose.model 'Homework', {
	id: String,
	homeworkName: String,
	deadLine: String,
	teacherID: String,
	submited: Array
}