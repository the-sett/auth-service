'use strict';

var authService = angular.module('authService', [
    'ngTable',    
    'ngResource',
    'ui.router',
    'ui.bootstrap',
    'toastr',
    'authService',
    'ui.router.menus'
]);

authService.config(function($stateProvider, $urlRouterProvider) {
    $urlRouterProvider.otherwise("/");
    
    $stateProvider.
        state('welcome', {
            url: '/welcome',
            templateUrl: '/app/views/welcome.html',
            data: {
                menu: 'none'
            }
        }).
        state('listAccount', {
            url: '/account',
            templateUrl: '/app/views/account-list.html',
            controller: 'AccountListController',
            data: {
                requireLogin: true,
                requirePermission: "admin",
                menu: 'main'
            },
            menu: {
                name: 'Accounts',
                tag: 'main'
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
                requirePermission: "admin",
                menu: 'main'
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
                requirePermission: "admin",
                menu: 'main'
            },
            resolve: {
                dtaRefData: function(RefDataService) {
                    return RefDataService.getRefData();
                },
                dtaAccount: function(AccountService, $stateParams) {
                    return AccountService.get({ id: $stateParams.id }).$promise;
                }
            }
        }).
        state('listRole', {
            url: '/role',
            templateUrl: '/app/views/role-list.html',
            controller: 'RoleListController',
            data: {
                requireLogin: true,
                requirePermission: "admin",
                menu: 'main'
            },
            menu: {
                name: 'Roles',
                tag: 'main'
            }
        }).
        state('listPermission', {
            url: '/permission',
            templateUrl: '/app/views/permission-list.html',
            controller: 'PermissionListController',
            data: {
                requireLogin: true,
                requirePermission: "admin",
                menu: 'main'
            },
            menu: {
                name: 'Permissions',
                tag: 'main'
            }
        });
});
