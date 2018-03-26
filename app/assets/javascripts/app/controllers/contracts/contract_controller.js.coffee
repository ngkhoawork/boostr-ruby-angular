@app.controller 'ContractController', [
    '$scope', '$routeParams', 'Contract'
    ($scope,   $routeParams,   Contract) ->
        $scope.contract = {}
        $scope.isRestricted = false
        $scope.isContractLoaded = false

        do getContract = ->
            Contract.get(id: $routeParams.id).then (contract) ->
                $scope.contract = contract
                $scope.isContractLoaded = true
            , (err) ->
                $scope.isRestricted = err.status is 403
                $scope.isContractLoaded = true
]
