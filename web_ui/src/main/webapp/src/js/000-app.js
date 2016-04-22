'use strict';

var authService = angular.module('authService', [
    'ngTable',    
    'ngResource',
    'ui.router',
    'ui.bootstrap',
    'toastr',
    'authService'
]);

authService.config(['$stateProvider', '$urlRouterProvider', function($stateProvider, $urlRouterProvider) {
    $urlRouterProvider.otherwise("/");
    
    $stateProvider.
        state('welcome', {
            url: '/welcome',
            templateUrl: '/app/views/welcome.html'
        }).
        state('listAccount', {
            url: '/account',
            templateUrl: '/app/views/account-list.html',
            controller: 'AccountListController',
            data: {
                requireLogin: true,
                requirePermission: "admin"
            },
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
            data: {
                requireLogin: true,
                requirePermission: "admin"
            },
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
            data: {
                requireLogin: true,
                requirePermission: "admin"
            },
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
