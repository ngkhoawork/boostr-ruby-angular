@app.controller "AccountsEditController",
['$scope', '$modalInstance', '$filter', 'Client', 'HoldingCompany', 'Field', 'AccountCfName', 'client', 'CountriesList', 'Validation'
($scope, $modalInstance, $filter, Client, HoldingCompany, Field, AccountCfName, client, CountriesList, Validation) ->
  $scope.client = client
  $scope.clients = []
  $scope.query = ""
  $scope.countries = []
  $scope.showAddressFields = Boolean(client.address and
    (client.address.country or
      client.address.street1 or
      client.address.city or
      client.address.state or
      client.address.zip))
  $scope.stateFieldRequired = false

  CountriesList.get (data) ->
    $scope.countries = data.countries

  AccountCfName.all().then (accountCfNames) ->
    $scope.accountCfNames = accountCfNames

  $scope.init = () ->
    $scope.formType = "Edit"
    $scope.submitText = "Update"

    getHoldingCompanies() 

    client_category_id = $scope.client.client_category_id
    if client_category_id
      $scope.setCategory(client_category_id)

    if $scope.client && $scope.client.address
      $scope.client.address.phone = $filter('tel')($scope.client.address.phone)

    Validation.account_base_fields().$promise.then (data) ->
      $scope.advertiser_base_fields_validations = data['Advertiser Base Field']
      $scope.agency_base_fields_validations = data['Agency Base Field']
      $scope.require_usa_state = _.find data['Account Custom Validation'], factor: 'Require USA State'
      $scope.default_segment = _.find data['Account Custom Validation'], factor: 'Default Segment - Not Top 100'
      
      Field.defaults($scope.client, 'Client').then (fields) ->
        if ($scope.client.client_type)
          selectedOption = $scope.client.client_type.option || null
        $scope.client.client_type = Field.field($scope.client, 'Client Type')
        if (selectedOption)
          $scope.client.client_type.options.forEach (option) ->
            if option.name == selectedOption
              $scope.client.client_type.option_id = option.id
        $scope.setClientTypes()
        $scope.getClients($scope.query)
        if $scope.require_usa_state && $scope.client.client_region && $scope.client.client_region['name'] == 'USA'
          $scope.stateFieldRequired = true
        if $scope.default_segment && !$scope.client.client_segment_id && segment = _.find($scope.client.fields[4].options, name: 'Not Top 100')
          $scope.client.client_segment_id = segment.id

  getHoldingCompanies = ->
    HoldingCompany.all({}).then (holdingCompanies) ->
      $scope.holdingCompanies = holdingCompanies

  $scope.submitForm = () ->
    $scope.errors = {}

    fields = ['name', 'client_type']

    fields.forEach (key) ->
      field = $scope.client[key]
      switch key
        when 'name'
          if !field then return $scope.errors[key] = 'Name is required'
        when 'client_type'
          if !field || !field.option_id then return $scope.errors[key] = 'Type is required'

    $scope.accountCfNames.forEach (item) ->
      if item.show_on_modal == true && item.is_required == true && (!$scope.client.account_cf || !$scope.client.account_cf[item.field_type + item.field_index])
        $scope.errors[item.field_type + item.field_index] = item.field_label + ' is required'

    if $scope.client.client_type.option_id == $scope.Advertiser
      base_fields_validation = $scope.advertiser_base_fields_validations
    else if $scope.client.client_type.option_id == $scope.Agency
      base_fields_validation = $scope.agency_base_fields_validations

    (base_fields_validation || []).forEach (validation) ->
      if $scope.client && (!$scope.client[validation.factor] && !$scope.client.address[validation.factor])
        $scope.errors[validation.factor] = validation.name + ' is required'

    if $scope.stateFieldRequired && !$scope.client.address['state']
      $scope.errors['state'] = 'State is required'

    if Object.keys($scope.errors).length > 0 then return
    $scope.buttonDisabled = true
    $scope.removeCategoriesFromAgency()
    $scope.client.$update(
      ->
        $modalInstance.close()
        $scope.$parent.$broadcast 'updated_current_client',
      (resp) ->
        $scope.errors = resp.data.errors
        $scope.buttonDisabled = false
    )

  $scope.clearErrors = () ->
    $scope.errors = {}

  $scope.baseFieldRequired = (factor) ->
    if $scope.client && $scope.client.client_type
      if $scope.client.client_type.option_id == $scope.Advertiser
        validation = _.findWhere($scope.advertiser_base_fields_validations, factor: factor)
        return validation?
      else if $scope.client.client_type.option_id == $scope.Agency
        validation = _.findWhere($scope.agency_base_fields_validations, factor: factor)
        return validation?

  $scope.getClients = (query = '') ->
    $scope.isLoading = true

    params =
      client_type_id: $scope.client.client_type.option_id,
      name: query.trim()

    Client.search_clients(params).$promise.then (clients) ->
      $scope.clients = clients
      $scope.isLoading = false

  # Prevent multiple extraneous calls to the server as user inputs search term
  searchTimeout = null;
  $scope.searchClients = (query) ->
    $scope.query = query
    if searchTimeout
      clearTimeout(searchTimeout)
      searchTimeout = null
    searchTimeout = setTimeout(
      -> $scope.getClients(query)
      250
    )

  $scope.setCategory = (id) ->
    $scope.client.fields.forEach (field) ->
      if (field.name == 'Category')
        field.options.forEach (category) ->
          if category.id == id
            $scope.current_category = category

  $scope.setClientTypes = () ->
    $scope.client.client_type.options.forEach (option) ->
      $scope[option.name] = option.id

  $scope.removeCategoriesFromAgency = () ->
    if $scope.client.client_type.option && $scope.client.client_type.option_id == $scope.Agency
      $scope.client.client_category_id = null
      $scope.client.client_subcategory_id = null

  $scope.updateCategory = (category) ->
    $scope.client.client_subcategory_id = undefined
    $scope.current_category = category

  $scope.cancel = ->
    $modalInstance.dismiss()

  $scope.onSelectRegion = (item, model) ->
    $scope.stateFieldRequired = $scope.require_usa_state && item.name == 'USA'
    $scope.errors = _.omit($scope.errors, 'state') unless $scope.stateFieldRequired
    $scope.showAddressFields = true if $scope.stateFieldRequired

  $scope.onSelectClientType = (item, model) ->
    if $scope.default_segment && $scope.Advertiser && model == $scope.Advertiser && !$scope.client.client_segment_id && segment = _.find($scope.client.fields[4].options, name: 'Not Top 100')
      $scope.client.client_segment_id = segment.id 

  $scope.init()
]
