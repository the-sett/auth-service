'use strict';

var auth-service = angular.module('auth-service', [
    'ngResource',
    'ui.router',
    'auth-service'
]);

auth-service.config(['$stateProvider'/*, '$stateParams'*/, '$urlRouterProvider', function($stateProvider/*, $stateParams*/, $urlRouterProvider) {
    $urlRouterProvider.otherwise("/");
    
    $stateProvider.
        state('root', {
            url: '/',
            templateUrl: 'views/class-editor.html',
            controller: 'ClassEditorController',
            resolve: {
                dtaRefData: function(RefDataService) {
                    return RefDataService.getRefData().$promise;                    
                }
            }
        });
}]);
