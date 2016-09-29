@app.controller 'ReportsController',
['$scope', '$rootScope', '$modal', '$routeParams', '$location', '$window', 'User', 'ActivityType', 'TimePeriod', 'Company',
($scope, $rootScope, $modal, $routeParams, $location, $window, User, ActivityType, TimePeriod, Company) ->

  $scope.users = []
  $scope.types = []
  $scope.timePeriods = []
  $scope.years = []
  $scope.currentTimePeriod = {}
  $scope.company = {}

  $scope.init = ->
    ActivityType.all().then (activityTypes) ->
      $scope.types = activityTypes
      TimePeriod.all().then (timePeriods) ->
        $scope.timePeriods = timePeriods
        if $routeParams.year
          $scope.year = $routeParams.year

        if $routeParams.time_period_id
          $scope.currentTimePeriod = _.find $scope.timePeriods, (timePeriod) ->
            "#{timePeriod.id}" == $routeParams.time_period_id
        else
          $scope.currentTimePeriod = timePeriods[0]
        User.query().$promise.then (users) ->
          $scope.users = users
          Company.get().$promise.then (company) ->
            $scope.company = company
            $scope.initReport()

  $scope.initReport = ->
    _.each $scope.users, (user) ->
      user.currentReportValues = []
      user.currentReportValues[0] = $scope.getReportValue(user.reports, $scope.types[0].name, $scope.currentTimePeriod.id)
      user.currentReportValues[1] = $scope.getReportValue(user.reports, $scope.types[1].name, $scope.currentTimePeriod.id)
      user.currentReportValues[2] = $scope.getReportValue(user.reports, $scope.types[2].name, $scope.currentTimePeriod.id)
      user.currentReportValues[3] = $scope.getReportValue(user.reports, $scope.types[3].name, $scope.currentTimePeriod.id)
      user.currentReportValues[4] = $scope.getReportValue(user.reports, $scope.types[4].name, $scope.currentTimePeriod.id)
      user.currentReportValues[5] = $scope.getReportValue(user.reports, $scope.types[5].name, $scope.currentTimePeriod.id)
      user.currentReportValues[6] = $scope.getReportValue(user.reports, $scope.types[6].name, $scope.currentTimePeriod.id)
      user.currentReportValues[7] = $scope.getReportValue(user.reports, $scope.types[7].name, $scope.currentTimePeriod.id)
      user.currentReportValues[8] = $scope.getReportValue(user.reports, $scope.types[8].name, $scope.currentTimePeriod.id)
      user.currentReportValues[9] = $scope.getReportValue(user.reports, 'Total', $scope.currentTimePeriod.id)
      user.currentReportValues[10] = $scope.getReportValue(user.reports, 'Weekly Average', $scope.currentTimePeriod.id)

    $scope.company.currentReportValues = []
    $scope.company.currentReportValues[0] = $scope.getCoReportValue($scope.company.reports, $scope.types[0].name, $scope.currentTimePeriod.id)
    $scope.company.currentReportValues[1] = $scope.getCoReportValue($scope.company.reports, $scope.types[1].name, $scope.currentTimePeriod.id)
    $scope.company.currentReportValues[2] = $scope.getCoReportValue($scope.company.reports, $scope.types[2].name, $scope.currentTimePeriod.id)
    $scope.company.currentReportValues[3] = $scope.getCoReportValue($scope.company.reports, $scope.types[3].name, $scope.currentTimePeriod.id)
    $scope.company.currentReportValues[4] = $scope.getCoReportValue($scope.company.reports, $scope.types[4].name, $scope.currentTimePeriod.id)
    $scope.company.currentReportValues[5] = $scope.getCoReportValue($scope.company.reports, $scope.types[5].name, $scope.currentTimePeriod.id)
    $scope.company.currentReportValues[6] = $scope.getCoReportValue($scope.company.reports, $scope.types[6].name, $scope.currentTimePeriod.id)
    $scope.company.currentReportValues[7] = $scope.getCoReportValue($scope.company.reports, $scope.types[7].name, $scope.currentTimePeriod.id)
    $scope.company.currentReportValues[8] = $scope.getCoReportValue($scope.company.reports, $scope.types[8].name, $scope.currentTimePeriod.id)
    $scope.company.currentReportValues[9] = $scope.getCoReportValue($scope.company.reports, 'Total', $scope.currentTimePeriod.id)
    $scope.company.currentReportValues[10] = $scope.getCoReportValue($scope.company.reports, 'Weekly Average', $scope.currentTimePeriod.id)

  $scope.$on 'updated_reports', ->
    $scope.init()

  $scope.init()

  $scope.getReportValue = (reports, name, timePeriodId) ->
    report = _.findWhere(reports, name: name, time_period_id: timePeriodId)
    if (report == undefined) || report.nil?
      return 0
    return report.value

  $scope.getCoReportValue = (reports, name, timePeriodId) ->
    report = _.findWhere(reports, name: name, time_period_id: timePeriodId, user_id: -1)
    if (report == undefined) || report.nil?
      return 0
    return report.value

  $scope.updateTimePeriod = (time_period) ->
    $scope.currentTimePeriod = time_period
    $scope.initReport()

  $scope.updateYear = (year) ->
    path = []

  $scope.exportReports = ->
    $window.open('/api/reports.csv')
    return true

]
