@app.controller 'LastWeekDealsReportController',
  ['$scope', '$window', 'LastWeekDealsReportService',
    ($scope, $window, LastWeekDealsReportService) ->
      $scope.report_data = {}

      init = ->
        LastWeekDealsReportService.get().$promise.then (data)->
          $scope.report_data = data
      init()
  ]