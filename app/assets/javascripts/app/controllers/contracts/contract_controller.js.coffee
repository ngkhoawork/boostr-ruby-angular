@app.controller 'ContractController', [
    '$scope', '$routeParams', 'Contract', 'Currency'
    ($scope,   $routeParams,   Contract,   Currency) ->
        $scope.contract = {}
        $scope.currencies = []
        $scope.isRestricted = false
        $scope.isContractLoaded = false

        do getContract = ->
            Contract.get(id: $routeParams.id).then (contract) ->
                $scope.contract = contract
                $scope.isContractLoaded = true
            , (err) ->
                $scope.isRestricted = err.status is 403
                $scope.isContractLoaded = true

        Currency.active_currencies().then (data) ->
            $scope.currencies = data
]
