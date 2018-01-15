@app.controller 'LeadsController', [
    '$scope', 'Leads'
    ($scope,   Leads) ->

        $scope.teamFilters = [
            {id: 'my_leads', name: 'My Leads'}
            {id: 'my_team_leads', name: 'My Team\'s Leads'}
            {id: 'all_leads', name: 'All'}
        ]
        $scope.typeFilters = [
            {id: 'new', name: 'New Leads', icon: 'external-link'}
            {id: 'accepted', name: 'Accepted', icon: 'check-square-o'}
            {id: 'rejected', name: 'Rejected', icon: 'square-o'}
        ]
        $scope.teamFilter = $scope.teamFilters[0]
        $scope.typeFilter = $scope.typeFilters[0]

        $scope.setTeamFilter = (item) -> $scope.teamFilter = item
        $scope.setTypeFilter = (item) -> $scope.typeFilter = item

        $scope.onFilterChange = (item) ->
            console.log item

        Leads.get().then (data) ->
            console.log data

]