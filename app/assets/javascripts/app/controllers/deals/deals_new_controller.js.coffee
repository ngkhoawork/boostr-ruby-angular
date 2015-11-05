@app.controller 'DealsNewController',
['$scope', '$modalInstance', '$q', '$location', 'Deal', 'Client', 'Stage', 'Field', 'deal',
($scope, $modalInstance, $q, $location, Deal, Client, Stage, Field, deal) ->

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
    $scope.buttonDisabled = true
    Deal.create(deal: $scope.deal).then (deal) ->
      $modalInstance.close()
      $location.path('/deals/' + deal.id)

  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()
]
