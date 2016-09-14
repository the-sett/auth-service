'use strict';

authService.controller('NavBarController', function($scope, $http, $filter, $state, $stateParams, $window, JWTUserProfile) {

    var vm = $scope;

    vm.logout = logout;
    vm.isAuthenticated = JWTUserProfile.isAuthenticated;
    vm.state = $state;
    
    vm.user = {};

    function logout() {
        JWTUserProfile.logout();
        $state.go('welcome');
    }
});
