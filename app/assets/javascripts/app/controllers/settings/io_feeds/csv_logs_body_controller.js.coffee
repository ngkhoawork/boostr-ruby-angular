@app.controller 'CsvLogsBodyController',
['$scope', '$document', '$modalInstance', '$sce', 'CsvImportLogs', 'log',
($scope, $document, $modalInstance, $sce, CsvImportLogs, log) ->

  $scope.log = log

  init = ->
    if log.rows_failed > 0
      CsvImportLogs.get(id: log.id).then (log) ->
        $scope.log.error_messages = log.error_messages

  $scope.showBodyModal = (body) ->

  $scope.cancel = ->
    $modalInstance.close()

  init()

]
