@app.controller 'AccountConnectionsEditController',
['$rootScope', '$scope', '$modal', '$modalInstance', '$q', '$location', 'ClientConnection', 'Client', 'Field', 'clientConnection'
($rootScope, $scope, $modal, $modalInstance, $q, $location, ClientConnection, Client, Field, clientConnection) ->
  $scope.init = ->
    $scope.formType = 'Edit'
    $scope.submitText = 'Update'
    $scope.advertisers = [clientConnection.advertiser]
    $scope.agencies = [clientConnection.agency]
    $scope.clientConnection = clientConnection

    Field.defaults({}, 'Client').then (fields) ->
      client_types = Field.findClientTypes(fields)
      $scope.setClientTypes(client_types)

  $scope.setClientTypes = (client_types) ->
    client_types.options.forEach (option) ->
      $scope[option.name] = option.id

  $scope.advertiserSelected = (model) ->
    $scope.clientConnection.advertiser_id = model

  $scope.agencySelected = (model) ->
    $scope.clientConnection.agency_id = model

  searchTimeout = null;
  $scope.searchClients = (query, type_id) ->
    if searchTimeout
      clearTimeout(searchTimeout)
      searchTimeout = null
    searchTimeout = setTimeout(
      -> $scope.loadClients(query, type_id)
      400
    )

  $scope.loadClients = (query, type_id) ->
    Client.search_clients({ name: query, client_type_id: type_id }).$promise.then (clients) ->
      if type_id == $scope.Advertiser
        $scope.advertisers = clients
      if type_id == $scope.Agency
        $scope.agencies = clients

  $scope.submitForm = () ->
    $scope.errors = {}

    fields = ['advertiser_id', 'agency_id', 'primary', 'active']

    fields.forEach (key) ->
      field = $scope.clientConnection[key]
      switch key
        when 'advertiser_id'
          if !field then return $scope.errors[key] = 'Advertiser is required'
        when 'agency_id'
          if !field then return $scope.errors[key] = 'Agency is required'

    if Object.keys($scope.errors).length > 0 then return

    ClientConnection.update(id: $scope.clientConnection.id, client_connection: $scope.clientConnection).then(
      (client_connection) ->
        $rootScope.$broadcast("updated_client_connections")
        $modalInstance.close(client_connection)
      (resp) ->
        for key, error of resp.data.errors
          $scope.errors[key] = error && error[0]
        $scope.buttonDisabled = false
    )

  $scope.cancel = ->
    $modalInstance.close()

  $scope.createNewClientModal = (option, target) ->
    $scope.populateClient = true
    $scope.populateClientTarget = target
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/client_form.html'
      size: 'md'
      controller: 'AccountsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        client: ->
          {
            client_type: {
              option: option
            }
          }
        options: -> {}
    # This will clear out the populateClient field if the form is dismissed
    $scope.modalInstance.result.then(
      null
      ->
        $scope.populateClient = false
        $scope.populateClientTarget = false
    )

  $scope.$on 'newClient', (event, client) ->
    if $scope.populateClient and $scope.populateClientTarget
      Field.defaults(client, 'Client').then (fields) ->
        client.client_type = Field.field(client, 'Client Type')
        $scope.clientConnection[$scope.populateClientTarget] = client.id
        $scope.populateClient = false
        $scope.populateClientTarget = false

  $scope.init()
]
