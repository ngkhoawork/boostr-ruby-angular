@app.controller 'IOEditController',
['$scope', '$modal', '$modalInstance', '$q', '$location', 'IO', 'IOMember', 'Deal', 'Field', 'Client', 'User', 'io',
($scope, $modal, $modalInstance, $q, $location, IO, IOMember, Deal, Field, Client, User, io) ->

  $scope.init = ->
    $scope.formType = 'Edit'
    $scope.advertisers = []
    $scope.agencies = []
    $scope.deals = []
    $scope.io = io
    $scope.ioMember = {}

    $scope.submitText = 'Update'

    Field.defaults({}, 'Client').then (fields) ->
      client_types = Field.findClientTypes(fields)
      $scope.setClientTypes(client_types)
      if io.advertiser_id
        $scope.loadClients(io.advertiser.name, $scope.Advertiser)
      if io.agency_id
        $scope.loadClients(io.agency.name, $scope.Agency)
      if io.deal_id
        $scope.loadDeals()

    User.query().$promise.then (users) ->
      $scope.users = users

  $scope.setClientTypes = (client_types) ->
    client_types.options.forEach (option) ->
      $scope[option.name] = option.id

  $scope.advertiserSelected = (model) ->
    $scope.io.advertiser_id = model

  $scope.agencySelected = (model) ->
    $scope.io.agency_id = model

  $scope.dealSelected = (model) ->
    $scope.io.deal_id = model

  searchTimeout = null;
  $scope.searchClients = (query, type_id) ->
    if searchTimeout
      clearTimeout(searchTimeout)
      searchTimeout = null
    searchTimeout = setTimeout(
      -> $scope.loadClients(query, type_id)
      400
    )

  $scope.searchDeals = (query) ->
    if searchTimeout
      clearTimeout(searchTimeout)
      searchTimeout = null
    searchTimeout = setTimeout(
      -> $scope.loadDeals(query)
      400
    )

  $scope.loadClients = (query, type_id) ->
    Client.search_clients( name: query, client_type_id: type_id ).$promise.then (clients) ->
      if type_id == $scope.Advertiser
        $scope.advertisers = clients
      if type_id == $scope.Agency
        $scope.agencies = clients

  $scope.loadDeals = (query) ->
    Deal.won_deals({ name: query }).then (deals) ->
      $scope.deals = deals

  $scope.submitForm = () ->
    IO.update(id: $scope.io.id, io: $scope.io).then(
      (io) ->
        $modalInstance.close(io)
      (resp) ->
        $scope.errors = resp.data.errors
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
        $scope.io[$scope.populateClientTarget] = client.id
        $scope.populateClient = false
        $scope.populateClientTarget = false

  $scope.init()
]
