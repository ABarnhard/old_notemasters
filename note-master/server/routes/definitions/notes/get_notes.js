'use strict';

var Note = require('../../../models/note');

module.exports = {
  description: 'Get All Notes for user',
  tags: ['notes'],
  handler: function(request, reply){
    Note.findAll(request.auth.credentials.id, function(err, notes){
      reply(notes);
    });
  }
};


