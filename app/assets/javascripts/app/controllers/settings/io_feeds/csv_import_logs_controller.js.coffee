@app.controller 'CsvImportLogsController',
  ['$scope', '$routeParams', '$modal', 'CsvImportLogs',
    ($scope, $routeParams, $modal, CsvImportLogs) ->

      $scope.requestUrl = "api/csv_import_logs"
      $scope.requestUrlParams = {
        exclude_source: 'ui'
      }

      $scope.showBodyModal = (log) ->
        $scope.modalInstance = $modal.open
          templateUrl: 'modals/csv_logs_body.html'
          size: 'lg'
          controller: 'CsvLogsBodyController'
          backdrop: 'static'
          keyboard: false
          resolve:
            log: ->
              log

  ]
