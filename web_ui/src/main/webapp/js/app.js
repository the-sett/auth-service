'use strict';

var jModeller = angular.module('jModeller', [
    'ngResource',
    'ui.router',
    'toastr',
    'jModeller'
]);

jModeller.config(['$stateProvider'/*, '$stateParams'*/, '$urlRouterProvider', function($stateProvider/*, $stateParams*/, $urlRouterProvider) {
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
