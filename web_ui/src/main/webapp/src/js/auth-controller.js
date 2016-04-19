'use strict';

authService.controller('AuthController', ['$scope', '$http', '$filter', '$state', '$stateParams', '$window', function($scope, $http, $filter, $state, $stateParams, $window) {

    var vm = $scope;

    vm.login = login;
    vm.logout = logout;
    vm.isAuthed = isAuthed;

    vm.user = {};

    function login() {
        console.log("login");
        
        $http
            .post('/auth/login', vm.user)
            .success(function (data, status, headers, config) {
                console.log(data);

                var base64Url = data.split('.')[1];
                var base64 = base64Url.replace('-', '+').replace('_', '/');
                var token = JSON.parse($window.atob(base64));

                console.log(token);
                
                $window.sessionStorage.userClaims = token;
                vm.message = 'Welcome';
                
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
            .post('/auth/logout', vm.user)
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
            .get('/auth/refresh')
            .success(function (data, status, headers, config) {
                console.log("Server authed check: " + data);

                return data;
            })
            .error(function (data, status, headers, config) {
                console.log("isAuthed error");
            });
    }
}]);
