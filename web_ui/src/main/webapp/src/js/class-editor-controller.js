'use strict';

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
