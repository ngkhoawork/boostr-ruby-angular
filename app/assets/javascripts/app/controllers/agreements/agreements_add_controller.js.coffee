@app.controller "AgreementsAddController",
['$scope', '$rootScope', '$filter', '$modal', '$modalInstance', '$location', 'Agreement', 'HoldingCompany', 'Field', 'Client', 'Publisher', 'CustomValue', 'options'
  ($scope, $rootScope, $filter, $modal, $modalInstance, $location, Agreement, HoldingCompany, Field, Client, Publisher, CustomValue, options) ->
    $scope.buttonDisabled = false
    isHoldingCompanyChoosen = false

    # Agreement options
    $scope.options =
      types: []
      statuses: []
      agencyHoldingCompanies: []
      advertisersParentsCompanies: []
      childAccountBrands: []
      publisher: []
      tracks: []
      max_start_date: options.deal.end_date if options && options.deal.end_date
      min_end_date: options.deal.start_date if options && options.deal.start_date
      max_start_date_formated: "Can't be after " + $filter('date')(options.deal.end_date) if options && options.deal.end_date
      min_end_date_formated: "Can't be before " + $filter('date')(options.deal.start_date) if options && options.deal.start_date
      requiredAgency: options.deal.agency if options && options.deal.agency
      requiredChildAccount: options.deal.advertiser if options && options.deal.advertiser
      disableChildAccount: false
      disableAgency: false

    if options
      if options.deal.advertiser && !options.deal.agency
        $scope.options.disableAgency = true
      if !options.deal.advertiser && options.deal.agency  
        $scope.options.disableChildAccount = true
      if options.deal.advertiser && options.deal.agency
        $scope.options.disableAgency = $scope.options.disableChildAccount = false

    # Agreement
    $scope.agreement =
      agencies: []
      advertisers: []
      child_accounts_brands: []
      publishers: []  

    init = ->
      getAgreementOptions()
      getHoldingCompanies()
      $scope.getPublishers()
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
              # Make $scope.getAgencies debounced after first call
              $scope.getAgencies = _.debounce($scope.getAgencies, 250)
        )

    showInfo = (message) ->
      $scope.infoModalInstance = $modal.open
        templateUrl: 'modals/info_modal.html'
        size: 'md'
        controller: 'AgreementInfoController'
        backdrop: 'static'
        keyboard: false
        resolve:
          options: ->
                  messages: [message]

    haveMandatoryFields = (query) ->
      $scope.errors = {}
      haveMandatoryAdvertiser = false
      haveMandatoryAgency = false

      if query.client_ids
        query.client_ids.forEach (clientId) ->
          if options.deal.advertiser && options.deal.advertiser.id == clientId
            haveMandatoryAdvertiser = true
          if options.deal.agency && options.deal.agency.id == clientId
            haveMandatoryAgency = true

      if options.deal.advertiser && options.deal.agency
        if query.client_ids
          if !haveMandatoryAdvertiser || !haveMandatoryAgency
            $scope.errors.child_accouns_brands = options.deal.advertiser.name
            $scope.errors.agency = options.deal.agency.name
            showInfo 'Agreement must contains Brands/Child Account - ' + options.deal.advertiser.name + ' and Agency - ' + options.deal.agency.name + '!'
            $scope.submitButtonDisabled = false
            return false    
        else
          $scope.errors.child_accouns_brands = options.deal.advertiser.name
          $scope.errors.agency = options.deal.agency.name
          showInfo 'Agreement must contains Brands/Child Account - ' + options.deal.advertiser.name + ' and Agency - ' + options.deal.agency.name + '!'
          $scope.submitButtonDisabled = false
          return false

      if options.deal.advertiser && !options.deal.agency && !query.client_ids
          console.log '6'
          $scope.errors.child_accouns_brands = options.deal.advertiser.name
          showInfo 'Agreement must contains Brands/Child Account - ' + options.deal.advertiser.name + '!'
          $scope.submitButtonDisabled = false
          return false

      if options.deal.agency && !options.deal.advertiser && !query.client_ids
          $scope.errors.agency = options.deal.agency.name
          showInfo 'Agreement must contains Agency - ' + options.deal.agency.name + '!'
          $scope.submitButtonDisabled = false
          return false

      if haveMandatoryAgency && options.deal.agency && !options.deal.advertiser
        return true
      else if haveMandatoryAdvertiser && options.deal.advertiser && !options.deal.agency
        return true
      else if !haveMandatoryAdvertiser && options.deal.advertiser && !options.deal.agency
        $scope.errors.child_accouns_brands = options.deal.advertiser.name
        showInfo 'Agreement must contains Brands/Child Account - ' + options.deal.advertiser.name + '!'
        $scope.submitButtonDisabled = false
        return false
      else if !haveMandatoryAgency && options.deal.agency && !options.deal.advertiser
        $scope.errors.agency = options.deal.agency.name
        showInfo 'Agreement must contains Agency - ' + options.deal.agency.name + '!'
        $scope.submitButtonDisabled = false
        return false

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

      query = getQuery()
    
      if options && options.deal && ( options.deal.advertiser || options.deal.agency )
        if haveMandatoryFields(query)
          Agreement.add(spend_agreement: query, (newAgreement) ->
            $scope.submitButtonDisabled = false
            $modalInstance.close(newAgreement)
          )
      else
        Agreement.add(spend_agreement: query, (newAgreement) ->
          $scope.submitButtonDisabled = false
          $modalInstance.close(newAgreement)
          $location.path '/agreements/' + newAgreement.id
        )

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
      
      if $scope.agreement.agencies.length > 0 && $scope.agreement.child_accounts_brands.length > 0
        agencyIds = $scope.agreement.agencies.map((agency) -> agency.id)
        childAccountBrandIds = $scope.agreement.child_accounts_brands.map((agency) -> agency.id)
        query.client_ids = agencyIds.concat childAccountBrandIds
      else if $scope.agreement.agencies.length > 0
        query.client_ids = $scope.agreement.agencies.map((agency) -> agency.id)
      else if $scope.agreement.child_accounts_brands.length > 0
        query.client_ids = $scope.agreement.child_accounts_brands.map((agency) -> agency.id)

      if $scope.agreement.status
        status_attributes = {
          field_id: $scope.agreement.status.field_id
          option_id: $scope.agreement.status.id
        }
        query.values_attributes.push(status_attributes)
      if $scope.agreement.spend_agreement_type
        type_attributes = {
          field_id: $scope.agreement.spend_agreement_type.field_id
          option_id: $scope.agreement.spend_agreement_type.id
        }
        query.values_attributes.push(type_attributes)  

      query

    $scope.cancel = -> $modalInstance.dismiss()

    getAgreementOptions = ->
      $scope.options.agencies = []
      $scope.options.advertisers = []
      $scope.options.child_accounts_brands = []
      $scope.options.publishers = []
      $scope.options.tracks = ["Manual", "Auto"]

    getHoldingCompanies = ->
      HoldingCompany.all({}).then (holdingCompanies) ->
        $scope.options.holding_companies = holdingCompanies

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
      Client.search_parent_clients({ client_type_id: $scope.advertiserType.id, search: search, 'exclude_ids[]': parentCompanyIDs }).$promise.then (advertisers) ->
        $scope.options.advertisers = advertisers
        
    $scope.changeAdvertiserParentCompanies = ->
      $scope.agreement.child_accounts_brands = []
      $scope.getChildAccountsBrands()

    $scope.getChildAccountsBrands = (search = '', notDisable) ->
      if $scope.agreement.child_accounts_brands and $scope.agreement.child_accounts_brands.length > 0
        childAccountBrandIDs = getIDs($scope.agreement.child_accounts_brands)
      else
        childAccountBrandIDs = null

      if $scope.agreement.parent_companies and $scope.agreement.parent_companies.length > 0
        parentCompanyIDs = getIDs($scope.agreement.parent_companies)
      else
        parentCompanyIDs = null

      if !notDisable
        $scope.disableChildClientsField = true
      Client.child_clients({ client_type_id: $scope.advertiserType.id, 'parent_clients[]': parentCompanyIDs, search: search, 'exclude_ids[]': childAccountBrandIDs }
        (child_clients) ->
          $scope.options.child_accounts_brands = child_clients
          $scope.disableChildClientsField = false
      )

    init()    
]
