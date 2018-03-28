@app.controller 'ContractController', [
    '$scope', '$modal', '$routeParams', 'Contract', 'Currency'
    ($scope,   $modal,   $routeParams,   Contract,   Currency) ->
        $scope.contract = {}
        $scope.currencies = []
        $scope.isRestricted = false
        $scope.isContractLoaded = false

        Currency.active_currencies().then (data) ->
            $scope.currencies = data

        do getContract = ->
            Contract.get(id: $routeParams.id).then (contract) ->
                $scope.contract = contract
                $scope.isContractLoaded = true
                $scope.showEditModal contract
            , (err) ->
                $scope.isRestricted = err.status is 403
                $scope.isContractLoaded = true

        $scope.updateContract = ->
            Contract.update($scope.contract)

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
]
