@app.controller 'ContractsFilterController', [
    '$scope', 'ContractsFilter', 'Contract', 'Client', 'Field', 'Deal'
    ($scope,   ContractsFilter,   Contract,   Client,   Field,   Deal) ->

        $scope.filter =
            deals: []
            advertisers: []
            agencies: []
            hodlingCompanies: []
            isOpen: false
            search: ''
            selected: ContractsFilter.selected
            get: ->
                s = this.selected
                filter = {}
                filter
            apply: (reset) ->
#                $scope.getContracts()
                if !reset then this.isOpen = false
            searching: (item) ->
                if !item then return false
                if item.name
                    return item.name.toString().toUpperCase().indexOf($scope.filter.search.toUpperCase()) > -1
                else
                    return item.toString().toUpperCase().indexOf($scope.filter.search.toUpperCase()) > -1
            reset: ContractsFilter.reset
            resetAll: -> ContractsFilter.resetAll
            select: ContractsFilter.select
            onDropdownToggle: ->
                this.search = ''
            open: ->
                this.isOpen = true
            close: ->
                this.isOpen = false

        Contract.filterValues().then (data) ->
            console.log data
            $scope.filter.deals = data.linked_deals
            $scope.filter.advertisers = data.linked_advertisers
            $scope.filter.agencies = data.linked_agencies
            $scope.filter.holdingCompanies = data.linked_holding_companies

]
