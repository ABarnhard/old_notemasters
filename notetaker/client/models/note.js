(function(){
  'use strict';

  angular.module('hapi-auth')
  .factory('Note', ['$http', function($http){

    function create(note){
      return $http.post('/notes', note);
    }

    function findAll(){
      return $http.get('/notes');
    }

    return {create:create, findAll:findAll};
  }]);
})();
