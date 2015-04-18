(function(){
  var mongoose;
  mongoose = require('mongoose');
  module.exports = mongoose.model('StuHomework', {
    hwid: String,
    sname: String,
    sid: String,
    content: String,
    grade: String
  });
}).call(this);
