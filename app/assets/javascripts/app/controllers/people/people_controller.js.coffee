@app.controller 'PeopleController', ['$scope', '$modal', ($scope, $modal) ->
  $scope.title = 'People'

  $scope.showModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/new_contact.html'
      size: 'lg'
      controller: ['$scope', '$modalInstance', ($scope, $modalInstance) ->
        $scope.ok = -> $modalInstance.close()
        $scope.cancel = -> $modalInstance.close()
      ]
]