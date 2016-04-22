'use strict';

authService.controller('AuthController', ['$scope', '$http', '$filter', '$state', '$stateParams', '$window', 'JWTUserProfile', function($scope, $http, $filter, $state, $stateParams, $window, JWTUserProfile) {

    var vm = $scope;

    vm.login = login;

    vm.user = {};

    function login() {
        JWTUserProfile.login(vm.user).then(function(result) {
            vm.message = 'Welcome';
            $scope.$close(true);
        }, function(reason) {
            vm.message = 'Invalid user or password';
        });
    }
}]);
