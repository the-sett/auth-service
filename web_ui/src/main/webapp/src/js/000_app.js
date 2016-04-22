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
                requirePermission: "test"
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
                requireLogin: true
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
                requireLogin: true
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

authService.run(['$rootScope', '$state', 'LoginModal', 'JWTUserProfile', function ($rootScope, $state, LoginModal, JWTUserProfile) {

    $rootScope.$on('$stateChangeStart', function (event, toState, toParams) {
        console.log(toState);
        
        if (toState.data) {
            var requireLogin = toState.data.requireLogin;

            if (requireLogin && JWTUserProfile.isAnonymous()) {
                event.preventDefault();

                LoginModal()
                    .then(function () {
                        return $state.go(toState.name, toParams);
                    })
                    .catch(function () {
                        return $state.go('welcome');
                    });
            }
        }
    });
}]);

authService.service('LoginModal', ['$modal', function ($modal) {

    return function() {
        var instance = $modal.open({
            templateUrl: '/app/views/login.html',
            controller: 'AuthController',
            controllerAs: 'AuthController'
        })

        return instance.result;
    };
}]);
