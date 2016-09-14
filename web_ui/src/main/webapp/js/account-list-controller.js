'use strict';

authService.controller('AccountListController', ['$scope', 'ngTableParams', 'AccountService', function($scope, ngTableParams, AccountService) {

    var vm = $scope;

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
