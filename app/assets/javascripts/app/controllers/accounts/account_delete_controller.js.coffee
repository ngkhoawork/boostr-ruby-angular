@app.controller "AccountDeleteController",
['$scope', '$rootScope', '$modal', '$modalInstance', 'error'
($scope, $rootScope, $modal, $modalInstance, error) ->
  $scope.error = error

  $scope.close = () ->
    $modalInstance.dismiss()
]
