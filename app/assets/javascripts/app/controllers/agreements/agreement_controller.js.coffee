@app.controller 'AgreementController',
['$scope', '$q', '$timeout', '$modal', '$location', '$routeParams', 'Agreement', 'CustomValue'
( $scope, $q, $timeout, $modal, $location, $routeParams, Agreement, CustomValue ) ->
    init = ->
        agreementId = $routeParams.id
        getAgreement(agreementId)
        
    $scope.dateOpened = {
        startDate: false
        endDate: false
    }

    $scope.limit = {
        default: 5
        agencies: 5
        publishers: 5
        advertisers: 5
    }

    $scope.showMore = (key) -> $scope.limit[key] = null

    $scope.showLess = (key) -> $scope.limit[key] = $scope.limit.default 

    getDeals = (id) ->
        Agreement.get_deals({ spend_agreement_id: id }
            (deals) -> $scope.agreement.deals = deals
            (reject) -> console.error reject    
        )

    getIOs = (id) ->
        Agreement.get_ios({ spend_agreement_id: id }
            (IOs) -> $scope.agreement.revenues = IOs
            (reject) -> console.error reject
        )

    getMembers = (id) ->
        Agreement.get_members({ spend_agreement_id: id }
            (members) -> $scope.agreement.team = members
            (reject) -> console.error reject    
        )    

    getBookedToTarget = ->
        revenueAmount = Number($scope.agreement.revenue_amount) if $scope.agreement.revenue_amount
        target = Number($scope.agreement.target) if $scope.agreement.target
        if revenueAmount && target
            $scope.agreement.bookedToTarget = ( ( revenueAmount / target ) * 100 ).toFixed(1)
        else
            $scope.agreement.bookedToTarget = 0    

    getForecastToTarget = ->
        revenueAmount = if $scope.agreement.revenue_amount then Number($scope.agreement.revenue_amount) else 0
        weightedPipelineAmount = if $scope.agreement.weighted_pipeline_amount then Number($scope.agreement.weighted_pipeline_amount) else 0
        target = if $scope.agreement.target then Number($scope.agreement.target) else 0
        if revenueAmount + weightedPipelineAmount && target
            $scope.agreement.forecastToTarget = ( ( ( revenueAmount + weightedPipelineAmount ) / target ) * 100 ).toFixed(1)
        else
            $scope.agreement.forecastToTarget = 0

    setAgreementCustomValues = ->
        $scope.agreement.values.forEach (value) ->
            $scope.options.spend_agreement_types.forEach (type) ->
                if type.id == value.option_id
                    $scope.agreement.spend_agreement_type = type
            $scope.options.statuses.forEach (status) ->
                if status.id == value.option_id
                    $scope.agreement.status = status

    getAgreement = (id) ->
        $scope.loaded = false
        Agreement.get({ id: id }
            (agreement) ->
                $scope.agreement = agreement
                $scope.agreement.allAdvertisers = agreement.parent_companies.concat(agreement.advertisers)
                $scope.disable = false
                $scope.agreement.track = if agreement.manually_tracked then "Manual" else "Auto"
                $scope.setPrevDate(agreement)
                angular.element('.agreement-clients').show()
                $q.all(
                    getDeals(id)
                    getIOs(id)
                    getMembers(id)
                    getAgreementOptions()
                    getBookedToTarget()
                    getForecastToTarget()
                ).then (data) -> $scope.loaded = true
            (reject) -> console.error reject    
        )

    $scope.updateAgreement = ->
        query = getQuery()
        Agreement.update { id: $scope.agreement.id, spend_agreement: query }, (data) ->
            if data.info_messages.length
                $scope.infoModalInstance = $modal.open
                    templateUrl: 'modals/info_modal.html'
                    size: 'md'
                    controller: 'AgreementInfoController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        options: ->
                            messages: data.info_messages
                            typeOfExcluded: 'deal'
                            typeOfUpdate: 'agreement'
            Agreement.get { id: $scope.agreement.id }, (newAgreement) -> getAgreement(newAgreement.id)

    getQuery = ->
        query = {
            name: $scope.agreement.name
            values_attributes: []
            start_date: $scope.agreement.start_date
            end_date: $scope.agreement.end_date
            target: $scope.agreement.target
            parent_companies_ids: $scope.agreement.parent_companies.map( (company) -> company.id ) if $scope.agreement.parent_companies
            publishers_ids: $scope.agreement.publishers.map( (publisher) -> publisher.id ) if $scope.agreement.publishers
            holding_company_id: $scope.agreement.holding_company.id if $scope.agreement.holding_company
            manually_tracked: if $scope.agreement.track == 'Manual' then true else false
        }
      
        if $scope.agreement.agencies && $scope.agreement.advertisers && $scope.agreement.agencies.length > 0 && $scope.agreement.advertisers.length > 0
            agencyIds = $scope.agreement.agencies.map (agency) -> agency.id
            childAccountBrandIds = $scope.agreement.advertisers.map (agency) -> agency.id
            query.client_ids = agencyIds.concat childAccountBrandIds
        else if $scope.agreement.agencies && $scope.agreement.agencies.length > 0
            query.client_ids = $scope.agreement.agencies.map (agency) -> agency.id
        else if $scope.agreement.advertisers && $scope.agreement.advertisers.length > 0
            query.client_ids = $scope.agreement.advertisers.map (agency) -> agency.id
        
        $scope.agreement.values.forEach (value) ->
            console.log 'value: ', value
            console.log '$scope.agreement.status: ', $scope.agreement.status
            console.log '$scope.agreement.spend_agreement_type: ', $scope.agreement.spend_agreement_type
            if $scope.agreement.status && value.field_id == $scope.agreement.status.field_id
                query.values_attributes.push {
                    id: value.id
                    field_id: value.field_id
                    option_id: $scope.agreement.status.id
                }
            if $scope.agreement.spend_agreement_type && value.field_id == $scope.agreement.spend_agreement_type.field_id
                query.values_attributes.push {
                    id: value.id
                    field_id: value.field_id
                    option_id: $scope.agreement.spend_agreement_type.id
                }

        if $scope.agreement.team
            $scope.agreement.team.forEach (memeber) ->
                if memeber.role
                    query.spend_agreement_team_member = [] if !query.spend_agreement_team_member
                    query.spend_agreement_team_member.push(memeber.role)
        query

    getAgreementOptions = ->
        $scope.options = {}
        $scope.disableCustomFields = true 
        $scope.options.tracks = ["Manual", "Auto"]
        CustomValue.all().then (custom_values) ->
            custom_values.forEach (value) ->
                if value.name == 'Multiple'
                    value.fields.forEach (field) ->
                        if field.name == 'Spend Agreement Status'
                            $scope.options.statuses = field.options
                        if field.name == 'Spend Agreement Type'
                            $scope.options.spend_agreement_types = field.options
                        if field.name == 'Spend Agreement Member Role'
                            $scope.options.roles = field.options
            if !$scope.agreement.spend_agreement_type || !$scope.agreement.status
                setAgreementCustomValues()
            $scope.disableCustomFields = false

    $scope.showAgreementEditModal = ->
        $scope.modalInstance = $modal.open
            templateUrl: 'modals/agreement/agreement_edit.html'
            size: 'md'
            controller: 'AgreementEditController'
            backdrop: 'static'
            keyboard: false
            resolve: 
                agreement: -> $scope.agreement
        .result.then (agreement) -> getAgreement(agreement.id) if agreement

    $scope.showAssignDealModal = ->
        $scope.modalInstance = $modal.open
            templateUrl: 'modals/agreement/agreement_assign_deals.html'
            size: 'md'
            controller: 'AgreementAssignDealsController'
            backdrop: 'static'
            keyboard: false
            resolve:
                agreement: -> $scope.agreement
        .result.then (dealIds) ->
            if dealIds
                query = getQuery()
                query.id = $scope.agreement.id
                query.spend_agreement_deals_attributes = dealIds
                Agreement.update( { id: $scope.agreement.id, spend_agreement: query },
                    (data) -> getAgreement($scope.agreement.id)
                    (reject) -> console.error reject
                )
            
    $scope.excludeDeal = (deal) ->
        if confirm('Are you sure you want to exclude "' +  deal.deal.name + '"?')
            Agreement.exclude_deal( { spend_agreement_id: $scope.agreement.id, id: deal.id }
                (data) -> getAgreement($scope.agreement.id)
                (reject) -> console.error reject    
            )

    $scope.showAddMemberModal = ->
        $scope.modalInstance = $modal.open
            templateUrl: 'modals/agreement/agreement_assign_members.html'
            size: 'md'
            controller: 'AgreementAssignMembersController'
            backdrop: 'static'
            keyboard: false
            resolve:
                agreement: -> $scope.agreement
        .result.then (membersIds) ->
            if membersIds
                query = getQuery()
                query.id = $scope.agreement.id
                query.spend_agreement_team_members_attributes = membersIds
                Agreement.update( { id: $scope.agreement.id, spend_agreement: query },
                    (data) -> getMembers($scope.agreement.id)
                    (reject) -> console.error reject
                )

    $scope.excludeMember = (member) ->
        memberName = member.user.first_name + ' ' + member.user.last_name
        if confirm('Are you sure you want to exclude "' +  memberName + '"?')
            Agreement.exclude_member( { spend_agreement_id: $scope.agreement.id, id: member.id }
                (data) -> getMembers($scope.agreement.id)
                (reject) -> console.error reject   
            ) 
            
    $scope.updateMember = (member, role) ->
        member.role = role.name
        query = {
            id: member.id
            values_attributes: [{
                option_id: role.id
                field_id: role.field_id
            }]
        }
        if member.values[0] then query.values_attributes[0].id = member.values[0].id
        Agreement.update_member(spend_agreement_id: $scope.agreement.id, id: member.id, { spend_agreement_team_member: query  })
            .$promise.then (data) -> member = data

    $scope.deleteAgreement = ->
        if confirm('Are you sure you want to delete "' +  $scope.agreement.name + '"?')
            Agreement.delete( { id: $scope.agreement.id }
                (res) -> $location.path '/agreements'
                (err) -> console.error (err)
            )

    $scope.setPrevDate = (agreement) ->
        $scope.prevStartDate = agreement.start_date
        $scope.prevEndDate = agreement.end_date 

    $scope.updateAgreementDate = (key) ->
      agreement = $scope.agreement
      $scope.errors = {}
      if agreement.start_date && agreement.end_date
        if key == 'start_date'
          if moment(agreement.start_date).isAfter(agreement.end_date)
            $scope.errors.start_date = 'End Date is before Start Date'
            $scope.agreement.start_date = $scope.prevStartDate
            $timeout (-> delete $scope.errors.start_date), 3000
          else
            delete $scope.errors.start_date
            delete $scope.errors.end_date
            $scope.prevStartDate = $scope.agreement.start_date
            $scope.updateAgreement()
        if key == 'end_date'
          if moment(agreement.start_date).isAfter(agreement.end_date)
            $scope.errors.end_date = 'End Date is before Start Date'
            $scope.agreement.end_date = $scope.prevEndDate
            $timeout (-> delete $scope.errors.end_date), 3000
          else
            delete $scope.errors.start_date
            delete $scope.errors.end_date
            $scope.prevEndDate = $scope.agreement.end_date
            $scope.updateAgreement()

    init()

]    