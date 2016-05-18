@app.controller 'DealsNewController',
['$scope', '$modal', '$modalInstance', '$q', '$location', 'Deal', 'Client', 'Stage', 'Field', 'deal',
($scope, $modal, $modalInstance, $q, $location, Deal, Client, Stage, Field, deal) ->

  $scope.init = ->
    $scope.formType = 'New'
    $scope.submitText = 'Create'
    $scope.advertisers = []
    $scope.agencies = []
    Field.defaults(deal, 'Deal').then (fields) ->
      deal.deal_type = Field.field(deal, 'Deal Type')
      deal.source_type = Field.field(deal, 'Deal Source')
      $scope.deal = deal
    $q.all({ clients: Client.all({ filter: 'all', per: 50 }), stages: Stage.query().$promise }).then (data) ->
      $scope.clients = data.clients
      #TODO this should go somewhere else...possibly the service
      _.each $scope.clients, (client) ->
        Field.defaults(client, 'Client').then (fields) ->
          client.client_type = Field.field(client, 'Client Type')
          if client.client_type.option.name == 'Advertiser'
            $scope.advertisers.push(client)
          if client.client_type.option.name == 'Agency'
            $scope.agencies.push(client)
      $scope.stages = data.stages

  $scope.advertiserSelected = (model) ->
    $scope.deal.advertiser_id = model

  $scope.agencySelected = (model) ->
    $scope.deal.agency_id = model

  $scope.loadClients = (query) ->
    Client.all({ filter: 'all', name: query, per: 50 }).then (clients) ->
      $scope.advertisers = []
      $scope.agencies = []
      _.each clients, (client) ->
        Field.defaults(client, 'Client').then (fields) ->
          client.client_type = Field.field(client, 'Client Type')
          if client.client_type.option.name == 'Advertiser'
            $scope.advertisers.push(client)
          if client.client_type.option.name == 'Agency'
            $scope.agencies.push(client)

  $scope.submitForm = () ->
    Deal.create(deal: $scope.deal).then (deal) ->
      $modalInstance.close()
      $location.path('/deals/' + deal.id)

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
