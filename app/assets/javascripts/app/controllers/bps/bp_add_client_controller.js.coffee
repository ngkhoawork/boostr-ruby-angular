@app.controller "BpAddClientController",
['$scope', '$modalInstance', '$filter', 'BP', 'BpEstimate', 'Client', 'bp'
($scope, $modalInstance, $filter, BP, BpEstimate, Client, bp) ->
  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.bp = bp
  $scope.searchText = ""
  BP.unassignedClients(id: $scope.bp.id).then (unassignedClients) ->
    $scope.clients = unassignedClients

  $scope.addClient = (client) ->
    BP.addClient(id: $scope.bp.id, client_id: client.id).then (bp) ->
      $modalInstance.close(bp)

  $scope.cancel = ->
    $modalInstance.close()
]
