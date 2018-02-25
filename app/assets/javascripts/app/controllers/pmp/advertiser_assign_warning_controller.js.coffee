@app.controller 'AdvertiserAssignWarningController',
  ['$scope', '$modalInstance', 'message',
  ( $scope,   $modalInstance,   message) ->
    $scope.message = message

    $scope.submit = () ->
      $modalInstance.close()

    $scope.cancel = () ->
      $modalInstance.dismiss()
  ]
