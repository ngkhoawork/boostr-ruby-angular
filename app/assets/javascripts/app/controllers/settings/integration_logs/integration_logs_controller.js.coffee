@app.controller 'IntegrationLogsController',
  ['$scope', '$routeParams', '$modal', 'IntegrationLogs',
    ($scope, $routeParams, $modal, Logs) ->

      $scope.errors_only = false
      $scope.logsUrl = 'api/integration_logs'
      $scope.logsUrlParams = {
        errors_only: $scope.errors_only
      }

      $scope.currentLog = null

      if $routeParams.id
        Logs.get($routeParams.id).then (log) ->
          $scope.currentLog = log

      $scope.setErrorFilter = (status) ->
        if status == $scope.errors_only
          return

        $scope.errors_only = status
        $scope.logsUrlParams.errors_only = status
        $scope.$broadcast('pagination:reload')

      $scope.getHost = (url) ->
        a = document.createElement('a')
        a.href = url
        host = a.host
        split = host.split('.')
        if split && split.length >= 2
          return split[split.length - 2]
        host

      $scope.resendRequest = (logId) ->
        Logs.resend(logId).then (data) ->
          console.log data

      $scope.showBodyModal = (log) ->
        $scope.modalInstance = $modal.open
          templateUrl: 'modals/logs_body.html'
          size: 'lg'
          controller: 'LogsBodyController'
          backdrop: 'static'
          keyboard: false
          resolve:
            body: ->
              log.response_body
            doctype: ->
              log.doctype
  ]
