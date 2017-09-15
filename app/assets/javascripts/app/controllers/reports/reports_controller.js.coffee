@app.controller 'ReportsController',
	['$scope', '$document', '$modal', '$routeParams', '$httpParamSerializer', '$location', '$window', '$filter', 'Team', 'User', 'ActivityType', 'TimePeriod', 'ActivityReport',
	( $scope,   $document,   $modal,   $routeParams,   $httpParamSerializer,   $location,   $window,   $filter,   Team,   User,   ActivityType,   TimePeriod,   ActivityReport ) ->
		$scope.teams = []
		$scope.types = []
		$scope.typeIds = {}
		$scope.userTypes = _.filter User.user_types_list, (type) -> type.id && type.id != 7 #excluding "Default" and "Fake User"
		emptyFilter = $scope.emptyFilter = {id: null, name: 'All'}

		defaultFilter =
			team: emptyFilter
			userType: emptyFilter
			date:
				startDate: null
				endDate: null

		$scope.filter = angular.copy defaultFilter
		appliedFilter = null

		$scope.datePicker =
			toString: (key) ->
				date = $scope.filter[key]
				if !date.startDate || !date.endDate then return false
				date.startDate.format('MMM D, YY') + ' - ' + date.endDate.format('MMM D, YY')

		$scope.setFilter = (key, val) ->
			$scope.filter[key] = val

		$scope.applyFilter = ->
			appliedFilter = angular.copy $scope.filter
			getReport getQuery()

		$scope.isFilterApplied = ->
			!angular.equals $scope.filter, appliedFilter

		$scope.resetFilter = ->
			$scope.filter = angular.copy defaultFilter

		getQuery = ->
			f = $scope.filter
			query = {}
			query.team_id = f.team.id || 'all'
			query.user_type = f.userType.id if f.userType.id
			if f.date.startDate && f.date.endDate
				query.start_date = f.date.startDate.format('YYYY-MM-DD')
				query.end_date = f.date.endDate.format('YYYY-MM-DD')
			query

		getReport = (query) ->
			$location.search query
			ActivityReport.get query, (report_data) ->
				$scope.user_activities = report_data.user_activities
				$scope.total_activities = report_data.total_activity_report
				$scope.initReport()

		updateFilterWithParams = (params) ->
			if params.team_id
				(searchAndSetTeam = (teams, teamId) ->
					for team in teams
						if team.id is teamId then return $scope.setFilter('team', team)
						if team.children && team.children.length then searchAndSetTeam team.children, teamId
				)($scope.teams, Number params.team_id)
			if params.user_type
				userType = _.findWhere $scope.userTypes, {id: Number params.user_type}
				$scope.setFilter('userType', userType) if userType
			if params.start_date && params.end_date
				$scope.filter.date =
					startDate: moment(params.start_date)
					endDate: moment(params.end_date)

		$scope.init = ->
			Team.all(all_teams: true).then (teams) ->
				$scope.teams = teams
				$scope.teams.unshift({
					id: 'all',
					name: 'All'
				})
				updateFilterWithParams($routeParams)
			ActivityType.all().then (activityTypes) ->
				$scope.types = angular.copy(activityTypes)
				_.each $scope.types, (type) ->
					$scope.typeIds[type.name] = type.id

		$scope.initReport = ->
			$scope.sortType = 'total'
			$scope.sortReverse = true

			$scope.userReportValues = []
			_.each $scope.user_activities, (report) ->
				fullReport = {}
				_.each $scope.types, (type) ->
					fullReport[type.name] = report[type.name] || 0
				fullReport.user_id = report.user_id
				fullReport.username = report.username
				fullReport.total = report.total
				$scope.userReportValues.push(fullReport)
			_.each $scope.types, (type) ->
				$scope.total_activities[type.name] = 0 if $scope.total_activities[type.name] == undefined

		#  $scope.drillActivityDetail = (member_id, type) ->
		#    if member_id == null
		#      member_id = ''
		#    if type == null
		#      type_id = ''
		#    else
		#      type_id = $scope.typeIds[type]
		#    query = {}
		#    query.team_id = f.team.id || 'all'
		#    query.user_type = f.userType.id if f.userType.id
		#    url = "/reports/activity_detail_reports"
		#    path.push "?team_id=all&member_id=#{member_id}&activity_type_id=#{type_id}"
		#
		#    if($scope.datePicker.startDate && $scope.datePicker.endDate && $scope.isDateSet)
		#      start_date = $filter('date')($scope.datePicker.startDate._d, 'yyyy-MM-dd')
		#      end_date = $filter('date')($scope.datePicker.endDate._d, 'yyyy-MM-dd')
		#      path.push "&start_date=#{start_date}&end_date=#{end_date}"
		#    $location.url(path.join(''))

		$scope.showActivityDetailModal = (memberId, typeId) ->
			$scope.modalInstance = $modal.open
				templateUrl: 'modals/activity_detail_table.html'
				size: 'xl'
				controller: 'ActivityDetailReportsController'
				backdrop: 'static'
				keyboard: false
				resolve:
					activitySummaryParams: ->
						{memberId, typeId, date: $scope.filter.date}

		$scope.changeSortType = (sortType) ->
			if sortType == $scope.sortType
				$scope.sortReverse = !$scope.sortReverse
			else
				$scope.sortType = sortType
				$scope.sortReverse = true

		$scope.$on 'updated_reports', ->
			$scope.init()

		$scope.init()

		$scope.exportReports = ->
			url = '/api/reports.csv'
			$window.open url + '?' + $httpParamSerializer getQuery()
			return

	]
