@app.controller "ClientsNewController",
['$scope', 'Client', '$modalInstance'
($scope, Client, $modalInstance) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  $scope.client = {}

  $scope.submitForm = () ->
    Client.create(client: $scope.client).then (client) ->
      Client.set(client)
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
