@app.controller 'ActivityNewController',
['$scope', '$modal', '$modalInstance', '$q', '$location', 'Deal', 'Client', 'Stage', 'Field',
($scope, $modal, $modalInstance, $q, $location, Deal, Client, Stage, Field) ->
  return null;

  $scope.init = ->
    $scope.formType = 'New'
    $scope.submitText = 'Create'
    $scope.advertisers = []
    $scope.agencies = []
    Field.defaults(deal, 'Deal').then (fields) ->
      deal.deal_type = Field.field(deal, 'Deal Type')
      deal.source_type = Field.field(deal, 'Deal Source')
      $scope.deal = deal

    Field.defaults({}, 'Client').then (fields) ->
      client_types = Field.findClientTypes(fields)
      $scope.setClientTypes(client_types)

    Stage.query().$promise.then (stages) ->
      $scope.stages = stages

  $scope.setClientTypes = (client_types) ->
    client_types.options.forEach (option) ->
      $scope[option.name] = option.id

  $scope.advertiserSelected = (model) ->
    $scope.deal.advertiser_id = model

  $scope.agencySelected = (model) ->
    $scope.deal.agency_id = model

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
    Client.query({ filter: 'all', name: query, per: 10, client_type_id: type_id }).$promise.then (clients) ->
      if type_id == $scope.Advertiser
        $scope.advertisers = clients
      if type_id == $scope.Agency
        $scope.agencies = clients

  $scope.submitForm = () ->
    Deal.create(deal: $scope.deal).then(
      (deal) ->
        $modalInstance.close()
        $location.path('/deals/' + deal.id)
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
      size: 'lg'
      controller: 'ClientsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        client: ->
          {
            client_type: {
              option: option
            }
          }
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
        $scope.deal[$scope.populateClientTarget] = client.id
        $scope.populateClient = false
        $scope.populateClientTarget = false

  $scope.init()
]
