'use strict';

authService.controller('AccountListController', ['$scope', '$http', '$filter', 'ngTableParams', 'RefDataService', 'ViewsService', 'AccountService', 'dtaRefData', function($scope, $http, $filter, ngTableParams, RefDataService, ViewsService, AccountService, dtaRefData) {

    var vm = $scope;

    vm.refData = {};
    angular.forEach(dtaRefData, function(ref) {
        vm.refData[ref.config.title] = ref.data;
    });

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
                AccountService.findAllTable($defer, params, params.filter(), this);
            },
            setCount: function(count) {
                vm.itemCount = count;
            }
        });

}]);
