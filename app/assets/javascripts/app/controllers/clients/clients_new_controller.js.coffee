@app.controller "ClientsNewController",
['$scope', 'Client', '$modalInstance'
($scope, Client, $modalInstance) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  $scope.client = {}
  $scope.clientTypes = Client.types()

  $scope.submitForm = () ->
    Client.create(client: $scope.client).then (client) ->
      Client.set(client.id)
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
