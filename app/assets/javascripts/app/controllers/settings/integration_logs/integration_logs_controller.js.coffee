@app.controller 'IntegrationLogsController',
  ['$scope', '$routeParams', '$modal', 'IntegrationLogs',
    ($scope, $routeParams, $modal, Logs) ->

      $scope.logs = []
      $scope.filter = 0
      $scope.currentLog = null

      Logs.all().then (logs) ->
        $scope.logs = logs
        if $routeParams.id
          console.log $routeParams.id
          $scope.currentLog = _.findWhere logs, {id: Number $routeParams.id}
          console.log $scope.currentLog

#      Logs.get(36).then (log) ->
#        console.log log

      $scope.getHost = (url) ->
        a = document.createElement('a')
        a.href = url
        host = a.host
        split = host.split('.')
        if split && split.length >= 2
          return split[split.length - 2]
        host

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