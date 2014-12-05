'use strict';

var bcrypt   = require('bcrypt'),
    request  = require('request'),
    path     = require('path'),
    AWS      = require('aws-sdk'),
    pg       = require('../postgres/manager'),
    crypto   = require('crypto');

function User(obj){
  this.username = obj.username;
}

User.register = function(obj, cb){
  var user = new User(obj);

  makeUrlandFile(obj.avatar, function(url, file){
    user.avatar = url;
    user.password = bcrypt.hashSync(obj.password, 10);

    var queryString = 'insert into users (username,password,avatar) values ($1,$2,$3) returning id',
        params      = [user.username, user.password, user.avatar];

    pg.query(queryString, params, function(err, results){
      if(!err){
        download(obj.avatar, file, function(){
          cb(err, results);
        });
      }else{
        cb(err, results);
      }
    });
  });
};

User.login = function(obj, cb){
  var queryString = 'select * from users where username = $1 limit 1',
      params      = [obj.username];

  pg.query(queryString, params, function(err, results){
    // console.log('ERR', err, 'RESULTS:', results);
    // no user found
    if(results.rowCount === 0){return cb(true, null);}

    var user = results.rows[0],
        isGood = bcrypt.compareSync(obj.password, user.password);
    // password is bad
    if(!isGood){return cb(true, null);}
    // all good
    cb(null, user);
  });
};

module.exports = User;

// PRIVATE HELPER FUNCTIONS //

function makeUrlandFile(url, cb){
  crypto.randomBytes(48, function(ex, buf){
    var token  = buf.toString('hex'),
        ext    = path.extname(url),
        file   = token + '.avatar' + ext,
        avatar = 'https://s3.amazonaws.com/' + process.env.AWS_BUCKET + '/' + file;

    cb(avatar, file);
  });
}

function download(url, file, cb){
  var s3   = new AWS.S3();

  request({url: url, encoding: null}, function(err, response, body){
    var params = {Bucket: process.env.AWS_BUCKET, Key: file, Body: body, ACL: 'public-read'};
    s3.putObject(params, cb);
  });

}

