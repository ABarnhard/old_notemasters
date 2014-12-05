(function(){
  'use strict';

  angular.module('note-master')
    .controller('NotesCtrl', ['$rootScope', '$scope', '$state', 'Note', function($rootScope, $scope, $state, Note){
      $scope.notes = [];

      Note.findAll().then(function(res){
        $scope.notes = res.data;
      });

      $scope.create = function(note){
        Note.create(note).then(function(res){
          $scope.notes.push(res.data);
        });
      };

    }]);
})();
