@app.controller "ClientsNewController",
['$scope', '$modalInstance', 'Client', 'ClientType',
($scope, $modalInstance, Client, ClientType) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  $scope.client = {}
  ClientType.all().then (clientTypes) ->
    $scope.clientTypes = clientTypes

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    Client.create(client: $scope.client).then (client) ->
      Client.set(client.id)
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
