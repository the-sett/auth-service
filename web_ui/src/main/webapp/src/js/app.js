'use strict';

var authService = angular.module('authService', [
    'ngTable',    
    'ngResource',
    'ui.router',
    'toastr',    
    'authService'
]);

authService.config(['$stateProvider'/*, '$stateParams'*/, '$urlRouterProvider', function($stateProvider/*, $stateParams*/, $urlRouterProvider) {
    $urlRouterProvider.otherwise("/");
    
    $stateProvider.
        state('root', {
            url: '/',
            templateUrl: 'app/views/main.html',
            controller: 'MainController',
            resolve: {
                dtaRefData: function(RefDataService) {
                    return RefDataService.getRefData().$promise;                    
                }
            }
        });
}]);
