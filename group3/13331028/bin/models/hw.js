(function(){
  var mongoose;
  mongoose = require('mongoose');
  module.exports = mongoose.model('Homework', {
    id: String,
    tid: String,
    request: String,
    deadline: String
  });
}).call(this);
