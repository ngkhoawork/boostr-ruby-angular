@app.controller 'LeadsController', [
    '$scope', '$modal', '$routeParams', '$location', 'Leads'
    ($scope,   $modal,   $routeParams,   $location,   Leads) ->

        $scope.isLoading = false
        $scope.leads = []
        $scope.search = ''
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
        $scope.teamFilter = _.findWhere($scope.teamFilters, id: $routeParams.relation) || null
        $scope.statusFilter = _.findWhere($scope.statusFilters, id: $routeParams.status) || null
        $location.search({})

        $scope.setTeamFilter = (item) -> $scope.teamFilter = item
        $scope.setTypeFilter = (item) -> $scope.statusFilter = item

        $scope.onFilterChange = (key, item) ->
            $scope[key] = item
            $scope.getLeads()

        $scope.getLeads = ->
            if !$scope.teamFilter || !$scope.statusFilter || $scope.isLoading then return
            $scope.isLoading = true
            params =
                relation: $scope.teamFilter.id
                status: $scope.statusFilter.id
                search: $scope.search if $scope.search
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
            modal = $modal.open
                templateUrl: 'modals/deal_form.html'
                controller: 'DealsNewController'
                size: 'md'
                resolve:
                    deal: -> {}
                    options: -> {lead}

            modal.result.then (deal) ->
                if deal && deal.id
                    lead.deals = lead.deals || []
                    lead.deals.push _.pick deal, ['id', 'name', 'budget']

        $scope.showAccountModal = (lead) ->
            modal = $modal.open
                templateUrl: 'modals/client_form.html'
                controller: 'AccountsNewController'
                size: 'md'
                resolve:
                    client: -> {}
                    options: -> {lead}

            modal.result.then (account) ->
                account.type = account.client_type_name
                if account && account.id then lead.client = account

        $scope.showContactModal = (lead) ->
            modal = $modal.open
                templateUrl: 'modals/contact_form.html'
                controller: 'ContactsNewController'
                size: 'md'
                resolve:
                    contact: -> {}
                    options: -> {lead}

            modal.result.then (contact) ->
                if contact && contact.id then lead.contact = contact

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

        $scope.$on 'updated_leads', $scope.getLeads
#        $scope.$on 'updated_lead', getLeads

]