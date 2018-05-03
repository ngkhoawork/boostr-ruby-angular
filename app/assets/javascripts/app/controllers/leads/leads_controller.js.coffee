@app.controller 'LeadsController', [
    '$scope', '$timeout', '$modal', '$routeParams', '$location', 'Leads', 'Validation'
    ($scope,   $timeout,   $modal,   $routeParams,   $location,   Leads,   Validation) ->

        $scope.isLoading = false
        $scope.leads = []
        $scope.search = ''
        page = 1
        leadsPerPage = 10
        rejection_explanation = false
        $scope.allLeadsLoaded = false
        $scope.leadsStatus = null
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
            $scope.getLeads(true)

        do getValidations = ->
            Validation.query(factor: 'Require Rejection Explanation').$promise.then (data) ->
                rejection_explanation = data && data[0]

        $scope.getLeads = (resetPagination)->
            if !$scope.teamFilter || !$scope.statusFilter || $scope.isLoading then return
            if resetPagination then page = 1
            $scope.isLoading = true
            params =
                per: leadsPerPage
                page: page
                relation: $scope.teamFilter.id
                status: $scope.statusFilter.id
                search: $scope.search if $scope.search
            Leads.get(params).then (data) ->
                $scope.allLeadsLoaded = !data || data.length < leadsPerPage
                if page++ > 1 then $scope.leads = $scope.leads.concat(data)
                else $scope.leads = data
                $scope.leadsStatus = params.status
                $scope.isLoading = false
                $timeout -> $scope.$emit 'leads:scroll'
            , (err) ->
                $scope.isLoading = false

        $scope.loadMoreLeads = ->
            if !$scope.allLeadsLoaded then $scope.getLeads()

        replaceLead = (lead) ->
            _.extend(_.findWhere($scope.leads, {id: lead.id}), lead)

        removeLead = (lead) ->
            $scope.leads = _.reject $scope.leads, (item) -> item.id is lead.id

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
            Leads.reassign(params).then -> removeLead(lead)

        $scope.mapAccount = (lead) ->
            clientId = lead._selectedClient.id if lead._selectedClient
            Leads.mapAccount({id: lead.id, client_id: clientId}).then ->
                lead.client = lead._selectedClient

        $scope.accept = (lead) ->
            Leads.accept(id: lead.id).then -> removeLead(lead)

        $scope.reject = (currentLead) ->
            if rejection_explanation && rejection_explanation.criterion.value
                $scope.showRejectionExplanationModal(currentLead)
                .result.then (lead) -> if lead then Leads.reject(id: lead.id).then -> removeLead(lead)
            else
                Leads.reject(id: currentLead.id).then -> removeLead(currentLead)

        $scope.showRejectionExplanationModal = (lead) ->
            $modal.open
                templateUrl: 'modals/leads_rejection_modal.html'
                size: 'md'
                controller: 'LeadsRejectionController'
                backdrop: 'static'
                keyboard: false
                resolve:
                    lead: -> lead
]
