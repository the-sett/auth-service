'use strict';

authService.controller('AuthController', ['$scope', '$http', '$filter', '$state', '$stateParams', '$window', function($scope, $http, $filter, $state, $stateParams, $window) {

    var vm = $scope;

    vm.register = register;
    vm.login = login;
    vm.logout = logout;
    vm.isAuthed = isAuthed;

    vm.user = {};

    function register() {
        console.log("register");
    }

    function login() {
        console.log("login");
        
        $http
            .post('/authenticate', vm.user)
            .success(function (data, status, headers, config) {
                $window.sessionStorage.token = data.token;
                vm.message = 'Welcome';
            })
            .error(function (data, status, headers, config) {
                delete $window.sessionStorage.token;
                vm.message = 'Error: Invalid user or password';
            });
    }

    function logout() {
        console.log("logout");
    }

    function isAuthed() {
        console.log("isAuthed");
    }
}]);
