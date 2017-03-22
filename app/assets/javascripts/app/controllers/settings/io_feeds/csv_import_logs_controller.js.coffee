@app.controller 'CsvImportLogsController',
  ['$scope', '$routeParams', '$modal', 'CsvImportLogs',
    ($scope, $routeParams, $modal, CsvImportLogs) ->

      $scope.logs = []

      CsvImportLogs.all().then (logs) ->
        $scope.logs = logs

      $scope.showBodyModal = (body) ->
        $scope.modalInstance = $modal.open
          templateUrl: 'modals/csv_logs_body.html'
          size: 'lg'
          controller: 'CsvLogsBodyController'
          backdrop: 'static'
          keyboard: false
          resolve:
            body: ->
              body

  ]
