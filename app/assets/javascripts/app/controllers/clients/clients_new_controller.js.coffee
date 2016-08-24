@app.controller "ClientsNewController",
['$scope', '$rootScope', '$modalInstance', 'Client', 'Field', 'client'
($scope, $rootScope, $modalInstance, Client, Field, client) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  $scope.client = new Client(client || {})
  $scope.clients = []
  $scope.query = ""

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

  $scope.getClients = (query) ->
    $scope.isLoading = true
    params = {
      page: $scope.page
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

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    $scope.removeCategoriesFromAgency()
    $scope.client.$save ->
      $rootScope.$broadcast 'newClient', $scope.client
      $modalInstance.close()

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
]
