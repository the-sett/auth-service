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
            .post('/api/auth/authenticate', vm.user)
            .success(function (data, status, headers, config) {
                $window.sessionStorage.userClaims = data;
                vm.message = 'Welcome';

                console.log(data);
                
                isAuthedServerCheck();
            })
            .error(function (data, status, headers, config) {
                delete $window.sessionStorage.userClaims;
                vm.message = 'Invalid user or password';

                isAuthedServerCheck();
            });
    }
    

    function logout() {
        console.log("logout");

        delete $window.sessionStorage.userClaims;

        $http
            .post('/api/auth/logout', vm.user)
            .success(function (data, status, headers, config) {
                vm.message = 'Logged Out';

                isAuthedServerCheck();
            })
            .error(function (data, status, headers, config) {
                vm.message = 'Error while logging out';

                isAuthedServerCheck();
            });
    }

    function isAuthed() {
        if ($window.sessionStorage.userClaims)
            return true;
        else
            return false;
    }

    function isAuthedServerCheck() {
        $http
            .get('/api/auth')
            .success(function (data, status, headers, config) {
                console.log("Server authed check: " + data);

                return data;
            })
            .error(function (data, status, headers, config) {
                console.log("isAuthed error");
            });
    }
}]);
