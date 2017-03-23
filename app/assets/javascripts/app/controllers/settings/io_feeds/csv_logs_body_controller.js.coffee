@app.controller 'CsvLogsBodyController',
['$scope', '$document', '$modalInstance', '$sce', 'body',
($scope, $document, $modalInstance, $sce, body) ->

  $scope.errors = body

  $scope.cancel = ->
    $modalInstance.close()

]
