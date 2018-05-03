@app.controller 'ContractsController', [
    '$scope', '$modal', '$timeout', 'Contract', 'ContractsFilter'
    ($scope,   $modal,   $timeout,   Contract,   ContractsFilter) ->

        $scope.contracts = []
        $scope.isLoading = false
        $scope.allContractsLoaded = false
        $scope.search = ''
        $scope.switches = [
            {name: 'My Contracts', param: 'my'}
            {name: 'My Team\'s Contracts', param: 'my_teams'}
            {name: 'All Contracts', param: 'all'}
        ]
        $scope.params =
            page: 1
            per: 10

        $scope.teamFilter = (value) ->
            if value then ContractsFilter.teamFilter = value else ContractsFilter.teamFilter

        if !$scope.teamFilter() then $scope.teamFilter $scope.switches[2]

        $scope.switchContracts = (swch) ->
            $scope.teamFilter swch
            $scope.getContracts(page: 1);

        $scope.showContractModal = ->
            $modal.open
                templateUrl: 'contracts/contract_form.html'
                controller: 'ContractFormController'
                size: 'md'
                backdrop: 'static'
                resolve:
                    contract: null

        ($scope.getContracts = (params) ->
            $scope.isLoading = true
            $scope.params.relation = $scope.teamFilter().param
            p = _.extend _.clone($scope.params), params || {}
            $scope.params.page = p.page
            Contract.all(p).then (contracts) ->
                $scope.allContractsLoaded = !contracts || contracts.length < p.per
                if $scope.params.page++ > 1
                    $scope.contracts = $scope.contracts.concat(contracts)
                else
                    $scope.contracts = contracts
                $scope.isLoading = false
                $timeout -> $scope.$emit 'lazy:scroll'
        )()

        $scope.loadMoreContracts = ->
            if !$scope.allContractsLoaded then $scope.getContracts()

        $scope.searchContracts = ->
            $scope.params.page = 1
            $scope.getContracts()

]
