@app.controller 'LeadsController', [
    '$scope', '$modal', 'Leads'
    ($scope,   $modal,   Leads) ->

        $scope.isLoading = false
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
            $scope.isLoading = true
            params =
                relation: $scope.teamFilter.id
                status: $scope.statusFilter.id
            Leads.get(params).then (data) ->
                data.status = params.status
                $scope.leads = data
                $scope.isLoading = false
            , (err) ->
                $scope.isLoading = false

        replaceLead = (lead) ->
            _.extend(_.findWhere($scope.leads, {id: lead.id}), lead)

        $scope.showReassignModal = (lead) ->
            $modal.open
                templateUrl: 'modals/lead_reassign.html'
                controller: 'LeadsReassignController'
                size: 'md'
                resolve:
                    lead: -> lead

        $scope.showDealModal = (lead) ->
            modalInstance = $modal.open
                templateUrl: 'modals/deal_form.html'
                controller: 'DealsNewController'
                size: 'md'
                resolve:
                    deal: -> {}
                    options: -> {lead}

            modalInstance.result.then (deal) ->
                if deal
                    lead.deals = lead.deals || []
                    lead.deals.push _.pick deal, ['id', 'name', 'budget']

        $scope.showAccountModal = (lead) ->
            $modal.open
                templateUrl: 'modals/client_form.html'
                controller: 'AccountsNewController'
                size: 'md'
                resolve:
                    client: -> {}
                    options: -> {lead}

        $scope.showContactModal = (lead) ->
            $modal.open
                templateUrl: 'modals/contact_form.html'
                controller: 'ContactsNewController'
                size: 'md'
                resolve:
                    contact: -> {}
                    options: -> {lead}

        $scope.reassign = (lead) ->
            params = {id: lead.id}
            params.user_id = $scope.currentUser.id if $scope.currentUser
            Leads.reassign(params)

        $scope.mapAccount = (lead) ->
            clientId = lead._selectedClient.id if lead._selectedClient
            Leads.mapAccount({id: lead.id, client_id: clientId}).then ->
                lead.client = lead._selectedClient

        $scope.accept = (lead) ->
            Leads.accept(id: lead.id)

        $scope.reject = (lead) ->
            Leads.reject(id: lead.id)

        $scope.$on 'updated_leads', getLeads
#        $scope.$on 'updated_lead', getLeads

]