@app.controller "BpAssignClientController",
['$scope', '$modalInstance', '$filter', 'BP', 'BpEstimate', 'Client', 'bp'
($scope, $modalInstance, $filter, BP, BpEstimate, Client, bp) ->
  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.bp = bp
  $scope.searchText = ""
  BP.unassignedClients(id: $scope.bp.id, all: true).then (unassignedClients) ->
    $scope.clients = unassignedClients

  $scope.addClient = (client) ->
    BP.assignClient(id: $scope.bp.id, client_id: client.id).then (bp) ->
      $modalInstance.close(bp)

  $scope.addAllClients = () ->
    BP.assignAllClients(id: $scope.bp.id).then (bp) ->
      $modalInstance.close(bp)

  $scope.searchObj = (name) ->
    if name == ""
      BP.unassignedClients(id: $scope.bp.id, all: true).then (unassignedClients) ->
        $scope.clients = unassignedClients
    else
      BP.unassignedClients(id: $scope.bp.id, all: true, name: name).then (unassignedClients) ->
        $scope.clients = unassignedClients
  $scope.cancel = ->
    $modalInstance.close()
]
