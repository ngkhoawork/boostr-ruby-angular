@app.controller 'LeadsController', [
    '$scope', '$modal', 'Leads'
    ($scope,   $modal,   Leads) ->

        $scope.leads = []
        $scope.teamFilters = [
            {id: 'my', name: 'My Leads'}
            {id: 'team', name: 'My Team\'s Leads'}
            {id: 'all', name: 'All'}
        ]
        $scope.statusFilters = [
            {id: 'new_leads', name: 'New Leads'}
            {id: 'accepted', name: 'Accepted'}
            {id: 'rejected', name: 'Rejected'}
        ]

        $scope.teamFilter = null
        $scope.statusFilter = null

        $scope.setTeamFilter = (item) -> $scope.teamFilter = item
        $scope.setTypeFilter = (item) -> $scope.statusFilter = item

        $scope.onFilterChange = (key, item) ->
            $scope[key] = item
            getLeads()

        getLeads = ->
            if !$scope.teamFilter || !$scope.statusFilter then return
            params =
                relation: $scope.teamFilter.id
                status: $scope.statusFilter.id
            Leads.get(params).then (data) ->
                data.status = params.status
                data.reverse() # --------------------------------------------------------------------------------------
                console.log data[0]
                $scope.leads = data

        $scope.showReassignModal = (lead) ->
            $modal.open
                templateUrl: 'modals/lead_reassign.html'
                controller: 'LeadsReassignController'
                size: 'md'
                resolve:
                    lead: -> lead


        $scope.reassign = (lead) ->
            params = {id: lead.id}
            params.user_id = $scope.currentUser.id if $scope.currentUser
            Leads.reassign(params)

        $scope.accept = (lead) ->
            Leads.accept(id: lead.id)

        $scope.reject = (lead) ->
            Leads.reject(id: lead.id)
]