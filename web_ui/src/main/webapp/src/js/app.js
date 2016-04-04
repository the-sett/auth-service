'use strict';

var authService = angular.module('authService', [
    'ngResource',
    'ui.router',
    'authService'
]);

authService.config(['$stateProvider'/*, '$stateParams'*/, '$urlRouterProvider', function($stateProvider/*, $stateParams*/, $urlRouterProvider) {
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
