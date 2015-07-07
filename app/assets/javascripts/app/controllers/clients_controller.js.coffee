@app.controller 'ClientsController', ['$scope', '$modal', ($scope, $modal) ->
  $scope.title = 'Clients'

  $scope.showModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/new_client.html'
      controller: ($scope, $modalInstance) ->
        $scope.ok = -> $modalInstance.close()
        $scope.cancel = -> $modalInstance.close()
]