'use strict';

var authService = angular.module('authService', [
    'ngTable',    
    'ngResource',
    'ui.router',
    'toastr',    
    'authService'
]);

authService.config(['$stateProvider', '$urlRouterProvider', function($stateProvider, $urlRouterProvider) {
    $urlRouterProvider.otherwise("/");
    
    $stateProvider.
        state('login', {
            url: '/login',
            templateUrl: '/app/views/login.html',
            controller: 'AuthController',
        }).
        state('listAccount', {
            url: '/account',
            templateUrl: '/app/views/account-list.html',
            controller: 'AccountListController',
            resolve: {
                dtaRefData: function(RefDataService) {
                    return RefDataService.getRefData().$promise;                    
                }
            }
        }).        
        state('newAccount', {
            url: '/account/new',
            templateUrl: '/app/views/account-create.html',
            controller: 'AccountCreateController',
            resolve: {
                dtaRefData: function(RefDataService) {
                    return RefDataService.getRefData();
                }
            }
        }).
        state('editAccount', {
            url: '/account/:id/edit',
            templateUrl: '/app/views/account-edit.html',
            controller: 'AccountEditController',
            resolve: {
                dtaRefData: function(RefDataService) {
                    return RefDataService.getRefData();
                },
                dtaAccount: function(AccountService, $stateParams) {
                    return AccountService.get({ id: $stateParams.id }).$promise;
                }
            }
        });
}]);
