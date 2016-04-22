authService.service('LoginModalService', ['$modal', function ($modal) {

    return function() {
        var instance = $modal.open({
            templateUrl: '/app/views/login.html',
            controller: 'LoginModalController',
            controllerAs: 'LoginModalController'
        })

        return instance.result;
    };
}]);
