require! ['mongoose']

module.exports =  mongoose.model 'Issue', {
    id: String,
    username: String,
    deadline: String,
    title: String,
    content: String
}