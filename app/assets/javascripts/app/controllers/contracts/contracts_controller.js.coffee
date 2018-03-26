@app.controller 'ContractsController', [
    '$scope', '$modal', '$timeout', 'Contract'
    ($scope,   $modal,   $timeout,   Contract) ->

        $scope.contracts = []
        $scope.isLoading = false
        $scope.allContractsLoaded = false
        $scope.search = ''
        page = 1
        perPage = 10

        $scope.showContractModal = ->
            $modal.open
                templateUrl: 'contracts/contract_form.html'
                controller: 'ContractFormController'
                size: 'md'
                backdrop: 'static'

        getContracts = ->
            $scope.isLoading = true
            params =
                per: perPage
                page: page
            Contract.all(params).then (contracts) ->
                $scope.allContractsLoaded = !contracts || contracts.length < perPage
                if page++ > 1
                    $scope.contracts = $scope.contracts.concat(contracts)
                else
                    $scope.contracts = contracts
                $scope.isLoading = false
                $timeout -> $scope.$emit 'lazy:scroll'

        $scope.loadMoreContracts = ->
            if !$scope.allContractsLoaded then getContracts()

        getContracts()


]
