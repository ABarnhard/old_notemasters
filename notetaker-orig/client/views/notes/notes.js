(function(){
  'use strict';

  angular.module('hapi-auth')
  .controller('NotesCtrl', ['$rootScope', '$scope', '$state', 'Note', function($rootScope, $scope, $state, Note){
    $scope.note = {};
    $scope.notes = [];

    getNotes();

    $scope.create = function(note){
      Note.create(note).then(function(response){
        $scope.note = {};
        getNotes();
        console.log(response.data);
      }, function(){
        console.log('error');
      });
    };

    function getNotes(){
      Note.findAll().then(function(res){
        $scope.notes = res.data;
      });
    }

  }]);
})();
