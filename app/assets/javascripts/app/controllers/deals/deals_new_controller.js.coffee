@app.controller 'DealsNewController',
['$scope', '$modalInstance', 'Deal', 'Client',
($scope, $modalInstance, Deal, Client) ->

  $scope.formType = 'New'
  $scope.submitText = 'Create'
  $scope.deal = {}

  Client.all (clients) ->
    $scope.clients = clients

  $scope.stages = Deal.stages()

  $scope.submitForm = () ->
    Deal.create(deal: $scope.deal).then (deal) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
