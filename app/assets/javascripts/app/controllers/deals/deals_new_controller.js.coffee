@app.controller 'DealsNewController',
['$scope', '$modalInstance', '$q', 'Deal', 'Client', 'Stage', 'deal',
($scope, $modalInstance, $q, Deal, Client, Stage, deal) ->

  $scope.formType = 'New'
  $scope.submitText = 'Create'
  $scope.deal = deal || {}
  Client.all().then (clients) ->
    $scope.clients = clients
  $scope.dealTypes = Deal.deal_types()
  $scope.sourceTypes = Deal.source_types()

  $scope.init = ->
    $q.all({ clients: Client.all(), stages: Stage.all() }).then (data) ->
      $scope.clients = data.clients
      $scope.stages = data.stages

  $scope.submitForm = () ->
    Deal.create(deal: $scope.deal).then (deal) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()
]
