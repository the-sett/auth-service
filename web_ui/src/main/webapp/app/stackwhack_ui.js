'use strict';

var auth-service = angular.module('auth-service', [
    'ngResource',
    'ui.router',
    'auth-service'
]);

auth-service.config(['$stateProvider'/*, '$stateParams'*/, '$urlRouterProvider', function($stateProvider/*, $stateParams*/, $urlRouterProvider) {
    $urlRouterProvider.otherwise("/");
    
    $stateProvider.
        state('root', {
            url: '/',
            templateUrl: 'views/class-editor.html',
            controller: 'ClassEditorController',
            resolve: {
                dtaRefData: function(RefDataService) {
                    return RefDataService.getRefData().$promise;                    
                }
            }
        });
}]);
;'use strict';

auth-service.controller('ClassEditorController', ['$scope', '$http', '$filter', 'RefDataService', 'ViewsService', 'dtaRefData', function($scope, $http, $filter, RefDataService, ViewsService, dtaRefData) {

    var vm = $scope;
    /*
    vm.refData = {};
    angular.forEach(dtaRefData, function(ref) {
        vm.refData[ref.config.title] = ref.data;
    });

    vm.refData.organisations = dtaOrganisations;
    
    $scope.itemCount = 0;
    
    $scope.tableParams = new ngTableParams(
        {
            page: 1,
            count: 10,
            sorting: { name : 'asc' }
        },
        {
            total: 0,
            getData: function($defer, params) {
                DashboardService.findAllTable($defer, params, params.filter(), this);
            },
            setCount: function(count) {
                vm.itemCount = count;
            }
        });
   */
}]);
;auth-service.constant('config', {
    "auth-service": {
        "endpoint": "http://localhost:9070/api/"
    }
});
;'use strict';

auth-service.service('RefDataService', function($resource, $http, config, $q) {

    var resource = $resource(config.auth-service.endpoint + 'refdata/:id', {
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
                        url: config.auth-service.endpoint + 'refdata/' + item,
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
;'use strict';

function lowerFirstLetter(string) {
    return string.charAt(0).toLowerCase() + string.slice(1);
}

function createRestService(name) {
    auth-service.service(name + 'Service', ['$http', '$filter', '$resource', 'config', function($http, $filter, $resource, config) {        
        function filterData(data, filter) {
            // Re-arrange nested filters so that they work. This only supports one level of nesting, but more
            // could be added by making the function recursive.
            var filters = {};
            
            angular.forEach(filter, function(value, key) {
                var splitedKey = key.match(/^([a-zA-Z]+)\.([a-zA-Z]+)$/);

                if(!splitedKey) {
                    filters[key] = value;
                    return;
                }

                splitedKey = splitedKey.splice(1);

                var father = splitedKey[0],
                    son = splitedKey[1];
                filters[father] = {};
                filters[father][son] = value;
            });

            return $filter('filter')(data, filters);
        }
        
        function orderData(data, params) {
            return params.sorting() ? $filter('orderBy')(data, params.orderBy()) : filteredData;
        }
        
        function sliceData(data, params) {
            return data.slice((params.page() - 1) * params.count(), params.page() * params.count())
        }
        
        function transformData(data, filter, params) {
            return sliceData(orderData(filterData(data, filter), params), params);
        }

        function tableResults(resultArray, $defer, params, filter, counter) {
            params.total(resultArray.length)
            var filteredData = $filter('filter')(resultArray, filter);
            var transformedData = transformData(resultArray, filter, params);
            
            $defer.resolve(transformedData);
            counter.setCount(filteredData.length);
        }
        
        var resource = $resource(config.auth-service.endpoint + lowerFirstLetter(name) + '/:id', {
            id: '@_id'
        }, {
            findAll: {
                method: 'GET',
                isArray: true,
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json; charset=utf-8'
                }
            },
            findByExample: {
                method: 'POST',
                isArray: true,
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json; charset=utf-8'
                },
                params: {
                    id: 'example'
                }
            },                
            create: {
                method: 'POST',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json; charset=utf-8'
                }
            },
            retrieve: {
                method: 'GET',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json; charset=utf-8'
                },
                params: {
                    id: '@id'
                }
            },
            update: {
                method: 'PUT',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json; charset=utf-8'
                },
                params: {
                    id: '@id'
                }
            },
            del: {
                method: 'DELETE',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json; charset=utf-8'
                },            
                params: {
                    id: '@id'
                }
            }        
        });
        
        resource.findAllTable = function($defer, params, filter, counter) {
            resource.findAll(function(resp) { tableResults(resp, $defer, params, filter, counter); });
        };

        resource.findByExampleTable = function(example, $defer, params, filter, counter) {
            resource.findByExample(example, function(resp) { tableResults(resp, $defer, params, filter, counter); });
        };

        return resource;
    }]);
}
/*
createRestService('Dashboard');
createRestService('TransactionSummaryUpload');
*/
;'use strict';

auth-service.service('ViewsService', function($resource, $http, config, $q) {

    var resource = $resource(config.auth-service.endpoint + 'view/:id', {
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
