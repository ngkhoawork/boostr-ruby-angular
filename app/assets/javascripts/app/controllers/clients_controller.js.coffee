@app.controller 'ClientsController', ['$scope', ($scope, $modal) ->
  $scope.title = 'Clients'

  $scope.showModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/new_client.html'
      controller: ($scope, $modalInstance) ->
        $scope.ok = -> $modalInstance.close()

]