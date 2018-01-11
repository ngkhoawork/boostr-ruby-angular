@app.controller 'EgnyteModalController',
  ['$scope', '$modalInstance', 'egnyte', '$sce', ( $scope, $modalInstance, egnyte, $sce ) ->

    $scope.embeddedEgnyte = $sce.trustAsResourceUrl(egnyte);

    console.log($scope.embeddedEgnyte)
    $scope.cancel = ->
      $modalInstance.close()
]