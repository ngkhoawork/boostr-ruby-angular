@app.controller "ClientsNewController",
['$scope', '$modalInstance', 'Client', 'Field',
($scope, $modalInstance, Client, Field) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  $scope.client = {}
  Field.defaults($scope.client, 'Client').then (fields) ->
    $scope.client.client_type = Field.field($scope.client, 'Client Type')

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    Client.create(client: $scope.client).then (client) ->
      Client.set(client.id)
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
