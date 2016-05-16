'use strict';

authService.controller('AccountCreateController', function($scope, $http, $filter, $state, toastr, RefDataService, ViewsService, AccountService, dtaRefData) {

    var vm = $scope;

    vm.create = create;
    
    vm.refData = {};
    angular.forEach(dtaRefData, function(ref) {
        vm.refData[ref.config.title] = ref.data;
    });

    console.log(vm.refData);

    vm.account = {};

    function create(account) {
        console.log(account);
        
        account.err = {};

        var need = new AccountService(account);

        need.$save().then(function(res) {
            toastr.success('Saved successfully', 'Success');
            $state.go('listAccount');
        }, function(err) {
            account.err = err.statusText;
            toastr.error('Did not save', 'Failure');
        });
    }    
});
