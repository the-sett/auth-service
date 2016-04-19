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
        state('login', {
            url: '/login',
            templateUrl: '/app/views/login.html',
            controller: 'AuthController',
        }).
        state('listAccount', {
            url: '/account',
            templateUrl: '/app/views/account-list.html',
            controller: 'AccountListController',
            data: {
                requireLogin: true
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

authService.run(['$rootScope', '$state', 'loginModal', function ($rootScope, $state, loginModal) {

    $rootScope.$on('$stateChangeStart', function (event, toState, toParams) {
        if (toState.data) {
            var requireLogin = toState.data.requireLogin;

            if (requireLogin && typeof $rootScope.currentUser === 'undefined') {
                event.preventDefault();

                loginModal()
                    .then(function () {
                        return $state.go(toState.name, toParams);
                    })
                    .catch(function () {
                        return $state.go('login');
                    });
            }
        }
    });
}]);


authService.service('loginModal', ['$modal', '$rootScope', function ($modal, $rootScope) {

    function assignCurrentUser (user) {
        $rootScope.currentUser = user;
        return user;
    }

    return function() {
        var instance = $modal.open({
            templateUrl: '/app/views/login.html',
            controller: 'AuthController',
            controllerAs: 'AuthController'
        })

        return instance.result.then(assignCurrentUser);
    };

}]);

/*
authService.controller('LoginModalCtrl', ['$scope', function ($scope) {

    this.cancel = $scope.$dismiss;

    this.submit = function (email, password) {
    };

}]);
*/
