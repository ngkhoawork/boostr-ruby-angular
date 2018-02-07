@app.controller "AccountsNewController",
['$scope', '$rootScope', '$modalInstance', 'Client', 'HoldingCompany', 'Field', 'AccountCfName', 'client', 'CountriesList', 'Validation', 'AccountsDuplicate'
($scope, $rootScope, $modalInstance, Client, HoldingCompany, Field, AccountCfName, client, CountriesList, Validation, AccountsDuplicate) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  client.address = {}
  $scope.client = new Client(client) || {address: {}}
  $scope.client.name = ""
  $scope.clients = []
  $scope.query = ""
  $scope.countries = []
  $scope.isDuplicateShow = false
  $scope.isLoaderShow = false
  $scope.duplicateItemsLimit = 5  # the maximum number of output duplicates

  CountriesList.get (data) ->
    $scope.countries = data.countries

  AccountCfName.all().then (accountCfNames) ->
    $scope.accountCfNames = accountCfNames

  HoldingCompany.all({}).then (holdingCompanies) ->
    $scope.holdingCompanies = holdingCompanies

  Field.defaults($scope.client, 'Client').then (fields) ->
    if ($scope.client.client_type)
      selectedOption = $scope.client.client_type.option || null
    $scope.client.client_type = Field.field($scope.client, 'Client Type')
    if (selectedOption)
      $scope.client.client_type.options.forEach (option) ->
        if option.name == selectedOption.name
          $scope.client.client_type.option_id = option.id
    $scope.setClientTypes()
    if $scope.client.client_type
      $scope.getClients($scope.query)

  Validation.account_base_fields().$promise.then (data) ->
    $scope.advertiser_base_fields_validations = data['Advertiser Base Field']
    $scope.agency_base_fields_validations = data['Agency Base Field']

  $scope.getClients = (query = '') ->
    $scope.isLoading = true

    params =
      client_type_id: $scope.client.client_type.option_id
      name: query.trim()

    Client.search_clients(params).$promise.then (clients) ->
      $scope.clients = clients
      $scope.isLoading = false

  # Prevent multiple extraneous calls to the server as user inputs search term
  searchTimeout = null;
  $scope.searchClients = (query) ->
    $scope.page = 1
    $scope.query = query
    if searchTimeout
      clearTimeout(searchTimeout)
      searchTimeout = null
    searchTimeout = setTimeout(
      -> $scope.getClients($scope.query)
      250
    )

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

    if Object.keys($scope.errors).length > 0 then return
    $scope.buttonDisabled = true
    $scope.removeCategoriesFromAgency()
    $scope.client.$save(
      (client)->
        $rootScope.$broadcast 'newClient', $scope.client
        $modalInstance.close(client)
      (resp) ->
        for key, error of resp.data.errors
          $scope.errors[key] = error && error[0]
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

  $scope.updateCategory = (category) ->
    $scope.client.client_subcategory_id = undefined
    $scope.current_category = category

  $scope.setClientTypes = () ->
    $scope.client.client_type.options.forEach (option) ->
      $scope[option.name] = option.id

  $scope.removeCategoriesFromAgency = () ->
    if $scope.client.client_type.option_id == $scope.Agency
      $scope.client.client_category_id = null
      $scope.client.client_subcategory_id = null

  $scope.cancel = ->
    $modalInstance.dismiss()

  $scope.closeDuplicateList = ->
    $scope.isDuplicateShow = false

  $scope.openDuplicateList = ->
     $scope.isDuplicateShow = true

  $scope.markDuplicateString = ->
    $scope.duplicates.forEach((duplicate) ->
      duplicateName = duplicate.name
      name = $scope.client.name
      index = duplicateName.toLowerCase().indexOf( name.toLowerCase() )

      if index >= 0
        re = new RegExp("(" + name + ")", "i");
        duplicate.name =  duplicateName.replace(re, '<strong>$1</strong>');
    )

  delayTimer = undefined
  $scope.onNameChanged = ->
    if $scope.client.name.length < 2
      $scope.closeDuplicateList()
    else
      $scope.openDuplicateList()
      $scope.isLoaderShow = true
      clearTimeout(delayTimer)
      delayTimer = setTimeout(
        -> AccountsDuplicate.query({ name: $scope.client.name }).$promise.then(
              (duplicates) ->
                $scope.isLoaderShow = false
                $scope.duplicates = duplicates
                $scope.markDuplicateString()
            )
        250
      )

  $scope.onFocus = ->
    if $scope.client.name.length < 2
      $scope.closeDuplicateList()
    else
      $scope.openDuplicateList()

  $scope.onBlur = ->
    if  $scope.duplicates.length == 0
      $scope.closeDuplicateList()

]
