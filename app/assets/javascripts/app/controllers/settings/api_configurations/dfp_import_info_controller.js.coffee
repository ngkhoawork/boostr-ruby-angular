@app.controller 'DfpImportInfoController',
  ['$scope', '$modalInstance', 'message'
    ($scope, $modalInstance, message) ->

      $scope.message = message

      $scope.cancel = ->
        $modalInstance.close()

  ]
