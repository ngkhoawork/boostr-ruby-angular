@app.controller 'ReportsController',
['$scope', '$document', '$rootScope', '$modal', '$routeParams', '$location', '$window', '$filter', 'Team', 'User', 'ActivityType', 'TimePeriod', 'Company', 'ActivityReport',
($scope, $document, $rootScope, $modal, $routeParams, $location, $window, $filter, Team, User, ActivityType, TimePeriod, Company, ActivityReport) ->

  $scope.users = []
  $scope.types = []
  $scope.typeIds = {}
  $scope.timePeriods = []
  $scope.years = []
  $scope.currentTimePeriod = {}
  $scope.company = {}

  $scope.$watch 'selectedTeam', () ->
    $scope.teamId = $scope.selectedTeam.id
    fetchData()

  $scope.datePickerApply = () ->
    if ($scope.datePicker.startDate && $scope.datePicker.endDate)
      datePickerInput.html($scope.datePicker.startDate.format('MMMM D, YYYY') + ' - ' + $scope.datePicker.endDate.format('MMMM D, YYYY'))
      $scope.isDateSet = true
      fetchData()

  $scope.datePickerCancel = (s, r) ->
    datePickerInput.html('Time period')
    $scope.isDateSet = false
    if !r then fetchData()

  $scope.resetFilters = () ->
    $scope.selectedTeam = {
      id:'all',
      name:'Team'
    }
    $scope.datePickerCancel(null, true)
    fetchData()
  $scope.init = ->
    $scope.teamId = ''
    $scope.selectedTeam = {
      id:'all',
      name:'Team'
    }  
    $scope.datePicker = {
      startDate: null
      endDate: null
    }
    $scope.isDateSet = false
    datePickerInput = $document.find('#kpi-date-picker')

    Team.all(all_teams: true).then (teams) ->
      $scope.teams = teams
      $scope.teams.unshift({
        id:'all',
        name:'All'
      })
    ActivityType.all().then (activityTypes) ->
      $scope.types = angular.copy(activityTypes)
      _.each $scope.types, (type) ->
        $scope.typeIds[cutSpace(type.name)] = type.id
      fetchData()

  fetchData = ->
    query = {}

    if($scope.teamId)
      query.team_id = $scope.teamId

    if($scope.datePicker.startDate && $scope.datePicker.endDate && $scope.isDateSet)
      query.start_date = $filter('date')($scope.datePicker.startDate._d, 'yyyy-MM-dd')
      query.end_date = $filter('date')($scope.datePicker.endDate._d, 'yyyy-MM-dd')
    if query.team_id
      ActivityReport.get(query, (report_data) ->
        $scope.user_activities = report_data.user_activities
        $scope.total_activities = report_data.total_activity_report
        $scope.initReport()
      )

  $scope.initReport = ->
    $scope.sortType = 'total'
    $scope.sortReverse = true

    $scope.userReportValues = []
    _.each $scope.user_activities, (report) ->
      fullReport = {}
      _.each $scope.types, (type) ->
        fullReport[cutSpace(type.name)] = report[type.name] || 0
      fullReport.user_id = report.user_id
      fullReport.username = report.username
      fullReport.total = report.total

      $scope.userReportValues.push(fullReport)
    console.log( $scope.userReportValues)

    _.each $scope.types, (type) ->
      $scope.total_activities[type.name] = 0 if $scope.total_activities[type.name] == undefined

  $scope.updateTimePeriod = (time_period_id) ->
    path = []
    path.push "/reports/activity_summary"
    path.push "?time_period_id=#{time_period_id}" if time_period_id
    $location.url(path.join(''))

  $scope.drillActivityDetail = (member_id, type) ->
    console.log(member_id)
    type_id = $scope.typeIds[type]
    path = []
    path.push "/reports/activity_detail_reports"
    path.push "?member_id=#{member_id}&type_id=#{type_id}"

    if($scope.datePicker.startDate && $scope.datePicker.endDate && $scope.isDateSet)
      start_date = $filter('date')($scope.datePicker.startDate._d, 'yyyy-MM-dd')
      end_date = $filter('date')($scope.datePicker.endDate._d, 'yyyy-MM-dd')
      path.push "&start_date=#{start_date}&end_date=#{end_date}" 
    $location.url(path.join(''))

  cutSpace = (string) ->
    angular.copy(string.replace(' ', ''))

  $scope.changeSortType = (sortType) ->
    sortType = cutSpace(sortType)
    if sortType == $scope.sortType
      $scope.sortReverse = !$scope.sortReverse
    else
      $scope.sortType = sortType
      $scope.sortReverse = true

  $scope.$on 'updated_reports', ->
    $scope.init()

  $scope.init()

  $scope.updateYear = (year) ->
    path = []

  $scope.exportReports = ->
    $window.open('/api/reports.csv')
    return true

]
