'use strict';

var pg = require('../postgres/manager');

function Note(obj){
  this.title = obj.title;
  this.body  = obj.body;
}

Note.findAll = function(userId, cb){
  var queryString = 'SELECT * FROM notes n where n.user_id = $1 ',
      params      = [userId];

  pg.query(queryString, params, function(err, results){
    if(!err){
      cb(err, results);
    }else{
      cb(err, results);
    }
  });
};

module.exports = Note;
