@app.controller "AccountsEditController",
['$scope', '$modalInstance', '$filter', 'Client', 'HoldingCompany', 'Field', 'AccountCfName', 'client', 'CountriesList'
($scope, $modalInstance, $filter, Client, HoldingCompany, Field, AccountCfName, client, CountriesList) ->
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


  CountriesList.get (data) ->
    $scope.countries = data.countries

  AccountCfName.all().then (accountCfNames) ->
    $scope.accountCfNames = accountCfNames

  $scope.init = () ->
    $scope.formType = "Edit"
    $scope.submitText = "Update"

    getHoldingCompanies()
    Field.defaults($scope.client, 'Client').then (fields) ->
      if ($scope.client.client_type)
        selectedOption = $scope.client.client_type.option || null
      $scope.client.client_type = Field.field($scope.client, 'Client Type')
      if (selectedOption)
        $scope.client.client_type.options.forEach (option) ->
          if option.name == selectedOption
            $scope.client.client_type.option_id = option.id
      $scope.setClientTypes()
      $scope.getClients()

    client_category_id = $scope.client.client_category_id
    if client_category_id
      $scope.setCategory(client_category_id)

    if $scope.client && $scope.client.address
      $scope.client.address.phone = $filter('tel')($scope.client.address.phone)

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

  $scope.getClients = (query) ->
    $scope.isLoading = true
    params = {
      page: $scope.page
      client_type_id: $scope.client.client_type.option_id
      filter: "all"
    }
    if $scope.query.trim().length
      params.name = $scope.query.trim()
    Client.query(params).$promise.then (clients) ->
      if $scope.page > 1
        $scope.clients = $scope.clients.concat(clients)
      else
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
      -> $scope.getClients()
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
    if $scope.client.client_type.option && $scope.client.client_type.option.name == 'Agency'
      $scope.client.client_category_id = null
      $scope.client.client_subcategory_id = null

  $scope.updateCategory = (category) ->
    $scope.client.client_subcategory_id = undefined
    $scope.current_category = category

  $scope.cancel = ->
    $modalInstance.dismiss()

  $scope.init()
]
