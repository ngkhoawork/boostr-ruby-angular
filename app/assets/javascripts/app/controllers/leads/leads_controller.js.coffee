@app.controller 'LeadsController', [
    '$scope', '$modal', 'Leads'
    ($scope,   $modal,   Leads) ->

        $scope.leads = []
        #    status -> new_leads, accepted, rejected
        #    relation -> my, team, all
        $scope.teamFilters = [
            {id: 'my', name: 'My Leads'}
            {id: 'team', name: 'My Team\'s Leads'}
            {id: 'all', name: 'All'}
        ]
        $scope.statusFilters = [
            {id: 'new_leads', name: 'New Leads', icon: 'external-link'}
            {id: 'accepted', name: 'Accepted', icon: 'check-square-o'}
            {id: 'rejected', name: 'Rejected', icon: 'square-o'}
        ]
        $scope.teamFilter = $scope.teamFilters[0]
        $scope.statusFilter = $scope.statusFilters[0]

        $scope.setTeamFilter = (item) -> $scope.teamFilter = item
        $scope.setTypeFilter = (item) -> $scope.statusFilter = item

        $scope.onFilterChange = (item) ->
            console.log 'SELECTED', item
            console.log $scope.teamFilter, $scope.statusFilter

        do getLeads = ->
            params = {}
#                relation: $scope.teamFilter.id
#                status: $scope.statusFilter.id
            Leads.get(params).then (data) ->
                console.log data
                $scope.leads = data

        $scope.showReassignModal = (lead) ->
            $modal.open
                templateUrl: 'modals/lead_reassign.html'
                controller: 'LeadsReassignController'
                size: 'md'
                resolve:
                    lead: -> lead
]