@app.controller 'ReportsController',
['$scope', '$rootScope', '$modal', '$routeParams', '$location', '$window', 'User', 'ActivityType', 'TimePeriod', 'Company', 'ActivityReport',
($scope, $rootScope, $modal, $routeParams, $location, $window, User, ActivityType, TimePeriod, Company, ActivityReport) ->

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
          timePeriods.some (timePeriod) ->
            if timePeriod.is_now
              $scope.currentTimePeriod = timePeriod
              return true
            return false
          if not $scope.currentTimePeriod
            $scope.currentTimePeriod = timePeriods[0]

        ActivityReport.query({time_period_id: $scope.currentTimePeriod.id}, (report_data) ->
          $scope.report_data = report_data
          $scope.initReport()
        )

  $scope.initReport = ->
    $scope.userReportValues = []
    _.each $scope.report_data, (report) ->
      _.each $scope.types, (type) ->
        report[type.name] = 0 if report[type.name] == undefined

      $scope.userReportValues.push(report)

  $scope.updateTimePeriod = (time_period_id) ->
    path = []
    path.push "/reports"
    path.push "?time_period_id=#{time_period_id}" if time_period_id
    $location.url(path.join(''))

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

  $scope.updateYear = (year) ->
    path = []

  $scope.exportReports = ->
    $window.open('/api/reports.csv')
    return true

]
