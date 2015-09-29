@app.controller "ClientsNewController",
['$scope', 'Client', '$modalInstance'
($scope, Client, $modalInstance) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  $scope.client = {}
  $scope.clientTypes = Client.types()

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    Client.create(client: $scope.client).then (client) ->
      Client.set(client.id)
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
