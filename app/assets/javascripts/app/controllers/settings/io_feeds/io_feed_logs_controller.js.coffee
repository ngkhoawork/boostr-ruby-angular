@app.controller 'IoFeedLogsController',
  ['$scope', '$routeParams', '$modal', 'CsvImportLogs',
    ($scope, $routeParams, $modal, CsvImportLogs) ->

      $scope.logs = []
      $scope.log_filter = 'datafeed'

      $scope.loadDatafeedLogs = ->
        CsvImportLogs.all(source: 'operative').then (logs) ->
          $scope.logs = logs

      $scope.loadDatafeedLogs()

      $scope.loadInboundApiLogs = ->
        CsvImportLogs.api_logs().then (logs) ->
          $scope.api_logs = logs

      $scope.setLogFilter = (filter) ->
        $scope.log_filter = filter

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
