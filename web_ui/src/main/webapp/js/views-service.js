'use strict';

jModeller.service('ViewsService', function($resource, $http, config, $q) {

    var resource = $resource(config.jmodeller.endpoint + 'view/:id', {
        id: '@id'
    }, {
        get: {
            method: 'GET',
            isArray: true,
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

    resource.getById = function(ref_name) {
        var deferred = $q.defer();
        
        resource.get({ id : ref_name }, function(res) {
            var refArray = [];
            
            angular.forEach(res, function(item) {
                refArray[item.id] = { id: item.id, name: item.name };
            });

            deferred.resolve($q.all(refArray));
        });

        return deferred.promise;
    }

    return resource;
});
