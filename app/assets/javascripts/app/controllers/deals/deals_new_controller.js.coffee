@app.controller 'DealsNewController',
['$scope', '$modalInstance', '$q', '$location', 'Deal', 'Client', 'Stage', 'deal',
($scope, $modalInstance, $q, $location, Deal, Client, Stage, deal) ->

  $scope.init = ->
    $scope.formType = 'New'
    $scope.submitText = 'Create'
    $scope.deal = deal
    $scope.dealTypes = Deal.deal_types()
    $scope.sourceTypes = Deal.source_types()
    $q.all({ clients: Client.all(), stages: Stage.all() }).then (data) ->
      $scope.clients = data.clients
      $scope.stages = data.stages

  $scope.submitForm = () ->
    Deal.create(deal: $scope.deal).then (deal) ->
      $modalInstance.close()
      $location.path('/deals/' + deal.id)

  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()
]
