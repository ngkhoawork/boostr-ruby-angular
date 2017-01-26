@app.controller 'ActivityDetailReportsController',
  ['$scope', '$document', '$rootScope', '$modal', '$routeParams', '$location', '$window', '$q', '$sce', 'Team', 'Activity', 'ActivityType', '$filter',
    ($scope, $document, $rootScope, $modal, $routeParams, $location, $window, $q, $sce, Team, Activity, ActivityType, $filter) ->
      $scope.sortType     = 'happened_at'
      $scope.sortReverse  = true
      $scope.filterOpen = true
      $scope.teamFilters = []
      $scope.memberFilters = []
      $scope.activityTypeFilters = []
      $scope.time_period = 'month'
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
        $scope.memberId = null
        $scope.activityTypeId = null
        $scope.selectedTeam = {
          id:'all',
          name:'Team'
        }
        $scope.datePickerCancel(null, true)
        fetchData()

      resetFilters = () ->
        $scope.memberFilters = []
        $scope.timeFilters = []
        $scope.activityTypeFilters = []

      fetchTeamMembers = (teamId) ->
        Team.all_members(team_id: teamId).then (members) ->
          $scope.members = members
          $scope.members.unshift({
            id:'all',
            name:'All'
          })

      fetchData = () ->
        query = {filter: "detail"}
        if($scope.activityTypeId)
          query.activity_type_id = $scope.activityTypeId

        if($scope.teamId)
          query.team_id = $scope.teamId

        if($scope.memberId)
          query.member_id = $scope.memberId

        if($scope.datePicker.startDate && $scope.datePicker.endDate && $scope.isDateSet)
          query.start_date = $filter('date')($scope.datePicker.startDate._d, 'dd-MM-yyyy')
          query.end_date = $filter('date')($scope.datePicker.endDate._d, 'dd-MM-yyyy')

        Activity.all(query).then (activities) ->
          $scope.activities = activities

      $scope.init = ->
#        Activity.all(filter: "detail").then (activities) ->
#          $scope.activities = activities
        Team.all(all_teams: true).then (teams) ->
          $scope.teams = teams
          $scope.teams.unshift({
            id:'all',
            name:'All'
          })
        fetchTeamMembers("all")

        ActivityType.all().then (activityTypes) ->
          $scope.activityTypes = angular.copy(activityTypes)
          $scope.activityTypes.unshift({
            id:'',
            name:'All'
          })

      $scope.init()

      $scope.filterByMember =(member) ->
        $scope.memberId = member
        fetchData()

      $scope.filterByActivityType =(activityTypeId) ->
        $scope.activityTypeId = activityTypeId
        fetchData()

      #team watcher
      $scope.$watch 'selectedTeam', () ->
        $scope.teamId = $scope.selectedTeam.id
        $scope.memberId = null
        fetchTeamMembers($scope.teamId)
        fetchData()

      #work with dates====================================================================
      $scope.endDateIsValid = undefined
      $scope.startDateIsValid = undefined

      $scope.$watch 'start_date', () ->
        checkDates()

      $scope.$watch 'end_date', () ->
        checkDates()

      checkDates = () ->
        end_date = new Date($scope.end_date).valueOf()
        start_date = new Date($scope.start_date).valueOf()

        if(end_date && start_date && end_date < start_date)
          $scope.endDateIsValid = false

        if(end_date && start_date && end_date > start_date)
          $scope.endDateIsValid = true
          $scope.startDateIsValid = true
          fetchData()

      $scope.go = (path) ->
        $location.path(path)

      $scope.exportReports = ->
        query_str = "filter=detail"
        if($scope.activityTypeId)
          query_str += "&activity_type_id=" + $scope.activityTypeId

        if($scope.teamId)
          query_str += "&team_id=" + $scope.teamId

        if($scope.memberId)
          query_str += "&member_id=" + $scope.memberId

        if($scope.datePicker.startDate && $scope.datePicker.endDate && $scope.isDateSet)
          start_date = $filter('date')($scope.datePicker.startDate._d, 'dd-MM-yyyy')
          end_date = $filter('date')($scope.datePicker.endDate._d, 'dd-MM-yyyy')
          query_str += "&start_date=" + start_date + "&end_date=" + end_date

        $window.open('/api/activities.csv?' + query_str)
        return true

      $scope.changeSortType = (sortType) ->
        if sortType == $scope.sortType
          $scope.sortReverse = !$scope.sortReverse
        else
          $scope.sortType = sortType
          $scope.sortReverse = false

      $scope.getHtml = (html) ->
        return $sce.trustAsHtml(html)

      $scope.showEmailsModal = (activity) ->
        $scope.modalInstance = $modal.open
          templateUrl: 'modals/activity_emails.html'
          size: 'lg'
          controller: 'ActivityEmailsController'
          backdrop: 'static'
          keyboard: false
          resolve:
            activity: ->
              activity
  ]
