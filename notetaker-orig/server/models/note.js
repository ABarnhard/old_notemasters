'use strict';

var pg = require('../postgres/manager');

function Note(){
}

Note.create = function(user, obj, cb){
  obj.tags = obj.tags || '';
  pg.query('select add_note($1, $2, $3, $4)', [user.id, obj.title, obj.body, obj.tags], function(err, results){
    console.log(err, results);
    cb();
  });
};

module.exports = Note;
