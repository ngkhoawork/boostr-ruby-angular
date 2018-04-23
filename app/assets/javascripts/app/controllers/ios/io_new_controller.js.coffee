@app.controller 'IONewController',
['$scope', '$modal', '$modalInstance', '$q', '$location', 'IO', 'IOMember', 'Deal', 'Field', 'Client', 'User', 'io', 'tempIO',
($scope, $modal, $modalInstance, $q, $location, IO, IOMember, Deal, Field, Client, User, io, tempIO) ->

  $scope.init = ->
    $scope.formType = 'New'
    $scope.advertisers = []
    $scope.agencies = []
    $scope.deals = []
    $scope.io = io
    $scope.ioMember = {}

    if (tempIO == null)
      $scope.submitText = 'Create'
    else
      $scope.submitText = 'Save & Assign'
      $scope.io.name = tempIO.name
      $scope.io.budget = tempIO.budget
      $scope.io.budget_loc = tempIO.budget_loc
      $scope.io.curr_cd = tempIO.curr_cd
      $scope.io.external_io_number = tempIO.external_io_number
      $scope.io.start_date = tempIO.start_date
      $scope.io.end_date = tempIO.end_date
      $scope.ioMember.from_date = tempIO.start_date
      $scope.ioMember.to_date = tempIO.end_date

    Field.defaults({}, 'Client').then (fields) ->
      client_types = Field.findClientTypes(fields)
      $scope.setClientTypes(client_types)

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
    Deal.all({ filter: 'all', name: query, per: 10 }).then (deals) ->
      $scope.deals = deals

  $scope.submitForm = () ->
    $scope.errors = {}

    IOValidations =
      name: (value) ->
        if !value then return 'is required'
      budget: (value) ->
        if !value then return 'is required'
        if isNaN value then return 'should be a number'
      advertiser_id: (value) ->
        if !value then return 'is not selected'
      start_date: (value) ->
        console.log value
        if !value then return 'is required'
      end_date: (value) ->
        if !value then return 'is required'

    IOMemberValidations =
      user_id: (value) ->
        if !value then return 'is not selected'
      share: (value) ->
        if !value then return 'is required'
        if isNaN value then return 'should be a number'
        if value < 0 or value > 100 then return 'should be 0 - 100'
      from_date: (value) ->
        if !value then return 'is required'
      to_date: (value) ->
        if !value then return 'is required'

    for key, validation of IOValidations
      error = validation($scope.io[key])
      $scope.errors[key] = error if error
    for key, validation of IOMemberValidations
      error = validation($scope.ioMember[key])
      $scope.errors[key] = error if error

    console.log $scope.errors
    if Object.keys($scope.errors).length > 0 then return

    IO.create(io: $scope.io).then(
      (io) ->
        IOMember.create(io_id: io.id, io_member: $scope.ioMember).then (ioMember) ->
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
