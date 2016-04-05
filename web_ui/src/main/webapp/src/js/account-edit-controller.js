'use strict';

authService.controller('AccountEditController', ['$scope', '$http', '$filter', '$state', '$stateParams', 'toastr', 'RefDataService', 'ViewsService', 'AccountService', 'dtaRefData', 'dtaAccount', function($scope, $http, $filter, $state, $stateParams, toastr, RefDataService, ViewsService, AccountService, dtaRefData, dtaAccount) {

    var vm = $scope;

    vm.update = update;
    vm.del = del;

    vm.refData = {};
    angular.forEach(dtaRefData, function(ref) {
        vm.refData[ref.config.title] = ref.data;
    });

    vm.account = dtaAccount;

    function update(account) {
        console.log(account);
        
        account.err = {};
        account.$update().then(function(res) {
            toastr.success('Saved successfully', 'Success');
            $state.go('root');            
        }, function(err) {
            account.err = err.statusText;
            toastr.error('Did not save', 'Failure');
        });
    }

    function del(account) {
        console.log(account);
        
        account.err = {};
        account.$del().then(function(res) {
            toastr.success('Deleted successfully', 'Success');
            $state.go('root');            
        }, function(err) {
            account.err = err.statusText;
            toastr.error('Did not delete', 'Failure');
        });
    }
}]);
