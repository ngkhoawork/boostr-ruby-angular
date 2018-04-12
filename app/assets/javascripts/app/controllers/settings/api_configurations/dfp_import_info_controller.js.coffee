@app.controller 'DfpImportInfoController',
  ['$scope', '$modalInstance', 'resp'
    ($scope, $modalInstance, resp) ->

      $scope.resp = resp

      $scope.cancel = ->
        $modalInstance.close()

  ]
