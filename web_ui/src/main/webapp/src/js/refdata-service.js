'use strict';

authService.service('RefDataService', function($resource, $http, config, $q) {

    var resource = $resource(config.authService.endpoint + 'refdata/:id', {
        id: '@id'
    }, {
        get: {
            method: 'GET',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json; charset=utf-8'
            },
            params: {
                id: '@id'
            }
        },
        query: {
            method: 'GET',
            isArray: true,
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json; charset=utf-8'
            }
        }
    });

    resource.getRefData = function() {

        var deferred = $q.defer();

        resource.query(function(res) {

            var refDataArray = [];

            angular.forEach(res, function(item) {
                refDataArray.unshift(
                    $http({
                        method: 'GET',
                        url: config.authService.endpoint + 'refdata/' + item,
                        cache: 'true',
                        title: item,
                        headers: {
                            'Accept': 'application/json',
                            'Content-Type': 'application/json; charset=utf-8'
                        }
                    })
                );
            });

            deferred.resolve($q.all(refDataArray));
        }, function() {
        });

        return deferred.promise;
    };

    return resource;
});
