@app.controller "ClientsEditController",
['$scope', '$modalInstance', '$filter', 'Client',
($scope, $modalInstance, $filter, Client) ->

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.client = Client.get()
  if $scope.client && $scope.client.address
    $scope.client.address.phone = $filter('tel')($scope.client.address.phone)

  $scope.submitForm = () ->
    Client.update(id: $scope.client.id, client: $scope.client).then (client) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
