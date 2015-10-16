@app.controller "ClientsEditController",
['$scope', '$modalInstance', '$filter', 'Client', 'ClientType',
($scope, $modalInstance, $filter, Client, ClientType) ->

  $scope.init = () ->
    $scope.formType = "Edit"
    $scope.submitText = "Update"

    $scope.client = Client.get()
    ClientType.all().then (clientTypes) ->
      $scope.clientTypes = clientTypes
      client_type_ids = _.map($scope.clientTypes, 'id')
      if client_type_ids.indexOf($scope.client.client_type_id) < 0
        $scope.clientTypes.push($scope.client.client_type)

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
