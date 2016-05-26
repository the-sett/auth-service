'use strict';

authService.controller('LoginModalController', function($scope, $http, $filter, $state, $stateParams, $window, $auth, JWTUserProfile) {

    var vm = $scope;

    vm.login = login;
    vm.dismiss = dismiss;

    vm.user = {};

    function login() {
        JWTUserProfile.login(vm.user).then(function(result) {
            vm.message = 'Welcome';
            $scope.$close(true);
        }, function(reason) {
            vm.message = 'Invalid user or password';
        });
    };

    $scope.authenticate = function(provider) {
      $auth.authenticate(provider);
    };

    function dismiss() { 
        $scope.$dismiss();
    }
});
