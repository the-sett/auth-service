'use strict';

function lowerFirstLetter(string) {
    return string.charAt(0).toLowerCase() + string.slice(1);
}

function createRestService(name) {
    authService.service(name + 'Service', ['$http', '$filter', '$resource', 'config', function($http, $filter, $resource, config) {
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
        
        var resource = $resource(config.authService.endpoint + lowerFirstLetter(name) + '/:id', {
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

createRestService('Account');
createRestService('Role');
createRestService('Permission');
