@app.controller "ClientsEditController",
['$scope', 'Client', '$modalInstance'
($scope, Client, $modalInstance) ->

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.client = Client.get()

  $scope.submitForm = () ->
    Client.update(id: $scope.client.id, client: $scope.client).then (client) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
