authService.config(function ($httpProvider) {

    $httpProvider.interceptors.push(function ($timeout, $q, $injector) {
        var LoginModalService, $http, $state;

        // this trick must be done so that we don't receive
        // `Uncaught Error: [$injector:cdep] Circular dependency found`
        $timeout(function () {
            LoginModalService = $injector.get('LoginModalService');
            $http = $injector.get('$http');
            $state = $injector.get('$state');
        });

        var loginShown = false;
        var loginModalPromise = null;
        
        return {
            responseError: function (rejection) {
                if (rejection.status !== 401) {
                    return rejection;
                }

                var deferred = $q.defer();

                console.log("login caused by 401");

                if (!loginShown) {
                    loginShown = true;
                    
                    loginModalPromise = LoginModalService();

                    loginModalPromise
                        .then(function () {
                            loginShown = false;
                            deferred.resolve($http(rejection.config));
                        })
                        .catch(function () {
                            loginShown = false;
                            $state.go('welcome');
                            deferred.reject(rejection);
                        });
                }
                else
                {
                    loginModalPromise.then(function() {
                        deferred.resolve($http(rejection.config));                        
                    });
                }

                return deferred.promise;
            }
        };
    });
});
