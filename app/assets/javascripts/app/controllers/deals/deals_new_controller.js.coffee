@app.controller 'DealsNewController',
['$scope', '$modal', '$modalInstance', '$q', '$location', 'Deal', 'Client', 'Stage', 'Field', 'deal',
($scope, $modal, $modalInstance, $q, $location, Deal, Client, Stage, Field, deal) ->

  $scope.init = ->
    $scope.formType = 'New'
    $scope.submitText = 'Create'
    Field.defaults(deal, 'Deal').then (fields) ->
      deal.deal_type = Field.field(deal, 'Deal Type')
      deal.source_type = Field.field(deal, 'Deal Source')
      $scope.deal = deal
    $q.all({ clients: Client.all({ filter: 'all' }), stages: Stage.all() }).then (data) ->
      $scope.clients = data.clients
      #TODO this should go somewhere else...possibly the service
      _.each $scope.clients, (client) ->
        Field.defaults(client, 'Client').then (fields) ->
          client.client_type = Field.field(client, 'Client Type')
      $scope.stages = data.stages

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
