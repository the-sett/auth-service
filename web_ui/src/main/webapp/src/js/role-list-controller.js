'use strict';

authService.controller('RoleListController', function($scope, ngTableParams, RoleService) {

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
                RoleService.findAllTable($defer, params, params.filter(), this);
            },
            setCount: function(count) {
                vm.itemCount = count;
            }
        });

});
