@app.controller "ClientsEditController",
['$scope', '$modalInstance', '$filter', 'Client', 'Field',
($scope, $modalInstance, $filter, Client, Field) ->

  $scope.init = () ->
    $scope.formType = "Edit"
    $scope.submitText = "Update"

    $scope.client = Client.get()

    Field.defaults($scope.client, 'Client').then (fields) ->
      $scope.client.client_type = Field.field($scope.client, 'Client Type')

    if $scope.client && $scope.client.address
      $scope.client.address.phone = $filter('tel')($scope.client.address.phone)

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    Client.update(id: $scope.client.id, client: $scope.client).then (client) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()
]
