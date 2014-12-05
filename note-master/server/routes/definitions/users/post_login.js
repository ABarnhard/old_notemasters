'use strict';

var Joi  = require('joi'),
    User = require('../../../models/user');

module.exports = {
  description: 'Login a User',
  tags:['users'],
  validate: {
    payload: {
      username: Joi.string().required(),
      password: Joi.string().required()
    }
  },
  auth: false,
  handler: function(request, reply){
    User.login(request.payload, function(err, user){
      if(err){return reply().code(401);}

      var authObj = {id: user.id, username: user.username, avatar: user.avatar};
      request.auth.session.set(authObj);
      reply(authObj);

    });
  }
};
