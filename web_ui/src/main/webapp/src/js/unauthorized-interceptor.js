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

        return {
            responseError: function (rejection) {
                if (rejection.status !== 401) {
                    return rejection;
                }

                var deferred = $q.defer();

                console.log("login caused by 401");
                
                LoginModalService()
                    .then(function () {
                        deferred.resolve($http(rejection.config));
                    })
                    .catch(function () {
                        $state.go('welcome');
                        deferred.reject(rejection);
                    });

                return deferred.promise;
            }
        };
    });
});
