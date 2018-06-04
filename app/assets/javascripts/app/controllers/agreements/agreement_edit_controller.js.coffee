@app.controller "AgreementEditController",
['$scope', '$rootScope', '$modal', '$modalInstance', 'agreement', 'Agreement', 'HoldingCompany', 'Field', 'Client', 'Publisher', 'CustomValue'
  ($scope, $rootScope, $modal, $modalInstance, agreement, Agreement, HoldingCompany, Field, Client, Publisher, CustomValue) ->

    init = ->
      $scope.agreement = angular.copy(agreement)
      $scope.agreement.track = if agreement.manually_tracked then "Manual" else "Auto"
      getAgreementOptions()
      getHoldingCompanies()
      $scope.getPublishers()
      Field.defaults({}, 'Client').then (fields) ->
        Field.findFieldOptions(fields, 'Client Type').forEach(
          (type) ->
            if type.name == 'Advertiser'
              $scope.advertiserType = type
              $scope.getAdvertiserParentCompanies()
              $scope.getChildAccountsBrands()
            if type.name == 'Agency' 
              $scope.agencyType = type
              $scope.getAgencies()
        )

    $scope.submitButtonDisabled = false

    $scope.submitForm = () ->
      $scope.errors = {}
      fields = ['name', 'spend_agreement_type', 'status', 'start_date', 'end_date', 'track']

      fields.forEach (key) ->
        field = $scope.agreement[key]
        switch key
          when 'name'
            if !field then return $scope.errors[key] = 'Name is required'
          when 'spend_agreement_type'
            if !field  then return $scope.errors[key] = 'Type is required'
          when 'status'
            if !field  then return $scope.errors[key] = 'Status is required'
          when 'start_date'
            if !field  then return $scope.errors[key] = 'Start Date is required'
          when 'end_date'
            if !field  then return $scope.errors[key] = 'End Date is required'
            if moment($scope.agreement.start_date).isAfter($scope.agreement.end_date)
              return $scope.errors[key] = 'End Date is before Start Date'
          when 'track'
            if !field  then return $scope.errors[key] = 'Track is required'

      if Object.keys($scope.errors).length > 0 then return
      $scope.submitButtonDisabled = true

      query = getQuery($scope.agreement)
      Agreement.update {id: $scope.agreement.id, spend_agreement: query}, (data) ->
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
        $scope.agreement.manually_tracked = data.manually_tracked
        $scope.agreement.status = $scope.agreement.status.name if $scope.agreement.status.name
        $scope.agreement.spend_agreement_type = $scope.agreement.spend_agreement_type.name if $scope.agreement.spend_agreement_type.name
        $modalInstance.close($scope.agreement)

    getQuery = ->
      query = {
        name: $scope.agreement.name
        values_attributes: []
        start_date: $scope.agreement.start_date
        end_date: $scope.agreement.end_date
        target: $scope.agreement.target
        parent_companies_ids: $scope.agreement.parent_companies.map( (company) -> company.id ) if $scope.agreement.parent_companies
        publishers_ids: $scope.agreement.publishers.map( (publisher) -> publisher.id ) if $scope.agreement.publishers
        holding_company_id: if $scope.agreement.holding_company then $scope.agreement.holding_company.id else null
        manually_tracked: if $scope.agreement.track == 'Manual' then true else false
      }
      
      if $scope.agreement.agencies && $scope.agreement.advertisers && $scope.agreement.agencies.length > 0 && $scope.agreement.advertisers.length > 0
        agencyIds = $scope.agreement.agencies.map((agency) -> agency.id)
        childAccountBrandIds = $scope.agreement.advertisers.map((agency) -> agency.id)
        query.client_ids = agencyIds.concat childAccountBrandIds
      else if $scope.agreement.agencies && $scope.agreement.agencies.length > 0
        query.client_ids = $scope.agreement.agencies.map((agency) -> agency.id)
      else if $scope.agreement.advertisers && $scope.agreement.advertisers.length > 0
        query.client_ids = $scope.agreement.advertisers.map((agency) -> agency.id)

      $scope.agreement.values.forEach (value) ->
        if value.field_id == $scope.agreement.status.field_id
          query.values_attributes.push {
            id: value.id
            field_id: value.field_id
            option_id: $scope.agreement.status.id
          }
        if value.field_id == $scope.agreement.spend_agreement_type.field_id
          query.values_attributes.push {
            id: value.id
            field_id: value.field_id
            option_id: $scope.agreement.spend_agreement_type.id
          }

      query

    $scope.cancel = ->
      $modalInstance.dismiss()

    setAgreementCustomValues = ->
        $scope.agreement.values.forEach (value) ->
          $scope.options.spend_agreement_types.forEach (type) ->
            if type.id == value.option_id
              $scope.agreement.spend_agreement_type = type
          $scope.options.statuses.forEach (status) ->
            if status.id == value.option_id
              $scope.agreement.status = status

    getAgreementOptions = ->
      $scope.options = {}
      $scope.disableCustomFields = true
      CustomValue.all().then (custom_values) ->
        custom_values.forEach (value) ->
          if value.name == 'Multiple'
            value.fields.forEach (field) ->
              if field.name == 'Spend Agreement Status'
                $scope.options.statuses = field.options
              if field.name == 'Spend Agreement Type'
                $scope.options.spend_agreement_types = field.options
        $scope.disableCustomFields = false
        if !$scope.agreement.spend_agreement_type || !$scope.agreement.status
          setAgreementCustomValues()
      $scope.options.tracks = ["Manual", "Auto"]

    getHoldingCompanies = ->
      HoldingCompany.all({}).then (holdingCompanies) ->
        $scope.options.holding_companies = holdingCompanies
        holdingCompanies.forEach(
          (holdingCompany) ->
            if holdingCompany.id == $scope.agreement.holding_company_id
              $scope.agreement.holding_company = holdingCompany
              $scope.chooseHoldingCompany(holdingCompany)
        )

    $scope.chooseHoldingCompany = (company) ->
      isHoldingCompanyChoosen = true
      $scope.agreement.holding_company = company
      $scope.agreement.agencies = []
      $scope.getAgencies()

    getIDs = (list) -> list.map (item) -> item.id

    $scope.getAgencies = (query = '', notDisable) ->
      if $scope.agreement.agencies
        agencyIDs = getIDs($scope.agreement.agencies)
      else
        agencyIDs = null

      if !notDisable
        $scope.disableAgencyField = true
      if $scope.agreement.holding_company
        HoldingCompany.relatedAccounts($scope.agreement.holding_company.id, query, agencyIDs).then (relatedAccounts) ->
          $scope.options.agencies = relatedAccounts
          $scope.disableAgencyField = false
      else
        HoldingCompany.relatedAccountsWithoutHolding(query, agencyIDs).then (relatedAccounts) ->
          $scope.options.agencies = relatedAccounts
          $scope.disableAgencyField = false

    $scope.filterPublisherOptions = ->
      (item) ->
        choosed = false
        $scope.agreement.publishers.forEach (publisher) ->
          if publisher.id == item.id then choosed = true
        !choosed 

    $scope.getPublishers = (name = '') ->
      Publisher.publishersList(q: name).then(
        (publishers) ->
          $scope.options.publishers = publishers
      )

    $scope.getAdvertiserParentCompanies = (search = '') ->
      if $scope.agreement.parent_companies
        parentCompanyIDs = getIDs($scope.agreement.parent_companies)
      else
        parentCompanyIDs = null

      Client.search_parent_clients({ client_type_id: $scope.advertiserType.id, search: search, 'exclude_ids[]': parentCompanyIDs }).$promise.then (parent_clients) ->
        $scope.options.parent_clients = parent_clients

    $scope.changeAdvertiserParentCompanies = ->
      $scope.agreement.advertisers = []
      $scope.getChildAccountsBrands()

    $scope.getChildAccountsBrands = (search = '', notDisable) ->
      if $scope.agreement.advertisers and $scope.agreement.advertisers.length > 0
        advertiserIDs = getIDs($scope.agreement.advertisers)
      else
        advertiserIDs = null

      if $scope.agreement.parent_companies and $scope.agreement.parent_companies.length > 0
        parentCompanyIDs = getIDs($scope.agreement.parent_companies)
      else
        parentCompanyIDs = null

      if !notDisable
        $scope.disableChildClientsField = true
      Client.child_clients({ client_type_id: $scope.advertiserType.id, 'parent_clients[]': parentCompanyIDs, search: search, 'exclude_ids[]': advertiserIDs }
        (child_clients) ->
          $scope.options.advertisers = child_clients
          $scope.disableChildClientsField = false
      ) 

    init()  
]
