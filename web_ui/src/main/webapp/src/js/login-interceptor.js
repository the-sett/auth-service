/**
 * The login interceptor. Routes requiring authentication are intercepted, and the user
 * directed to login prior to the route being followed.
 */
authService.run(['$rootScope', '$state', 'LoginModalService', 'JWTUserProfile', function ($rootScope, $state, LoginModalService, JWTUserProfile) {

    $rootScope.$on('$stateChangeStart', function (event, toState, toParams) {
        console.log(toState);
        
        if (toState.data) {
            var requireLogin = toState.data.requireLogin;
            var requiredPermission = toState.data.requirePermission;

            console.log("requiredLogin = " + requireLogin);
            console.log("requiredPermission = " + requiredPermission);
            
            function checkPermission() {
                if (requiredPermission) {
                    if (!JWTUserProfile.hasPermission(requiredPermission)) {
                        event.preventDefault();
                        return $state.go('welcome');
                    }
                }
            }
            
            if (requireLogin && JWTUserProfile.isAnonymous()) {
                event.preventDefault();

                LoginModalService()
                    .then(function () {
                        return $state.go(toState.name, toParams);
                    })
                    .catch(function () {
                        return $state.go('welcome');
                    });
            }

            checkPermission();
        }
    });
}]);
