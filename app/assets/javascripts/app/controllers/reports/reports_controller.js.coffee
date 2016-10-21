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
    $scope.sortType = 'user.name' #init value
    $scope.sortReverse = false  #init value

    #user reports
    $scope.userReportValues = []
    _.each $scope.users, (user) ->
      report = {}
      report.user = user
      _.each $scope.types, (type) ->
        typeName = cutSpace(type.name)
        report[typeName] = $scope.getReportValue(user.reports, type.name, $scope.currentTimePeriod.id)
      report['Total'] = $scope.getReportValue(user.reports, 'Total', $scope.currentTimePeriod.id)
#     report['Weekly Average'] = $scope.getReportValue(user.reports, 'Weekly Average', $scope.currentTimePeriod.id)
      $scope.userReportValues.push(report)

    #companyReports
    $scope.companyReports = {}
    _.each $scope.types, (type) ->
      typeName = cutSpace(type.name)
      $scope.companyReports[typeName] = $scope.getCoReportValue($scope.company.reports, type.name, $scope.currentTimePeriod.id)
    $scope.companyReports['Total'] = $scope.getCoReportValue($scope.company.reports, 'Total', $scope.currentTimePeriod.id)
    #$scope.companyReports['Weekly Average'] = $scope.getReportValue($scope.company.reports, 'Weekly Average', $scope.currentTimePeriod.id)

  cutSpace = (string) ->
    angular.copy(string.replace(' ', ''))

  $scope.changeSortType = (sortType) ->
    sortType = cutSpace(sortType)
    if sortType == $scope.sortType
      $scope.sortReverse = !$scope.sortReverse
    else
      $scope.sortType = sortType
      $scope.sortReverse = false

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
