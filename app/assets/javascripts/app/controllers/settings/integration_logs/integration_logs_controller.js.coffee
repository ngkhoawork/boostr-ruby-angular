@app.controller 'IntegrationLogsController',
  ['$scope', '$routeParams', '$modal', 'IntegrationLogs',
    ($scope, $routeParams, $modal, Logs) ->

      $scope.logs = []
      $scope.filter = 0
      $scope.currentLog = null

      if $routeParams.id
        Logs.get($routeParams.id).then (log) ->
          $scope.currentLog = log
      else
        Logs.all().then (logs) ->
          $scope.logs = logs

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
