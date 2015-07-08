@app.controller "ClientsNewController",
['$scope', 'Client', '$modalInstance'
($scope, Client, $modalInstance) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  $scope.client = {}

  $scope.submitForm = () ->
    Client.save client: $scope.client, (client) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
