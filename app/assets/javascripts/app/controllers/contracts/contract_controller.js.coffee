@app.controller 'ContractController', [
    '$scope', '$modal', '$filter', '$routeParams', '$location', 'Contract', 'Currency', 'User'
    ($scope,   $modal,   $filter,   $routeParams,   $location,   Contract,   Currency,   User) ->
        $scope.contract = {}
        $scope.currencies = []
        $scope.users = []
        $scope.isRestricted = false
        $scope.isContractLoaded = false

        Currency.active_currencies().then (data) ->
            $scope.currencies = data

        do getContract = ->
            Contract.get(id: $routeParams.id).then (contract) ->
                $scope.contract = contract
                $scope.isContractLoaded = true
#                $scope.showSpecialTermModal(contract)
            , (err) ->
                $scope.isRestricted = err.status is 403
                $scope.isContractLoaded = true

        $scope.updateContract = ->
            Contract.update(id: $scope.contract.id, contract: $scope.contract)

        $scope.addContact = (contract) ->
            $scope.modalInstance = $modal.open
                templateUrl: 'modals/contact_add_form.html'
                controller: 'ContractAssignContactController'
                size: 'md'
                backdrop: 'static'
                resolve:
                    contract: -> contract

        $scope.showEditModal = (contract) ->
            modalInstance = $modal.open
                templateUrl: 'contracts/contract_form.html'
                controller: 'ContractFormController'
                size: 'md'
                backdrop: 'static'
                resolve:
                    contract: -> angular.copy contract
            modalInstance.result.then (contract) ->
                _.extend $scope.contract, contract

        $scope.deleteContract = (contract) ->
            if confirm('Are you sure you want to delete "' + contract.name + '"?')
                Contract.delete {id: contract.id}, (res) ->
                    $location.path('/contracts')
                , (err) ->
                    console.log (err)

        $scope.showLinkExistingUser = ->
            User.query().$promise.then (users) ->
                $scope.users = $filter('notIn')(users, $scope.contract.contract_members, 'user_id')

        $scope.linkExistingUser = (item) ->
            Contract.update
                id: $scope.contract.id
                contract: {contract_members_attributes: [user_id: item.id]}
            .then (data) ->
                _.extend $scope.contract, data

        $scope.showSpecialTermModal = (contract) ->
            $modal.open
                templateUrl: 'contracts/contract_special_term_form.html'
                controller: 'ContractSpecialTermController'
                size: 'md'
                backdrop: 'static'
                resolve:
                    contract: -> contract

]
