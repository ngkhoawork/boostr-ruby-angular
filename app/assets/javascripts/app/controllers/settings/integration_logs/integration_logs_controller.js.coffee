@app.controller 'IntegrationLogsController',
  ['$scope', '$modal', 'IntegrationLogs',
    ($scope, $modal, Logs) ->

      $scope.logs = []

      Logs.all().then (logs) ->
        $scope.logs = logs
        console.log logs[1]

#      Logs.get(36).then (log) ->
#        console.log log

      $scope.showBodyModal = (body) ->
        $scope.modalInstance = $modal.open
          templateUrl: 'modals/logs_body.html'
          size: 'lg'
          controller: 'LogsBodyController'
          backdrop: 'static'
          keyboard: false
          resolve:
            body: ->
              body
  ]