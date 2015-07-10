@app.controller 'ClientsController',
['$scope', '$modal', 'Client',
($scope, $modal, Client) ->

  $scope.showModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/new_client.html'
      size: 'lg'
      controller: 'ClientsNewController'
      backdrop: 'static'
      keyboard: false

]
