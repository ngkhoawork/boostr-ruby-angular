@app.controller 'ReportsController',
	['$scope', '$modal', '$httpParamSerializer', '$window', 'Team', 'User', 'ActivityType', 'ActivityReport',
	( $scope,   $modal,   $httpParamSerializer,   $window,   Team,   User,   ActivityType,   ActivityReport ) ->

		$scope.teams = []
		$scope.types = []
		$scope.typeIds = {}
		$scope.userTypes = _.filter User.user_types_list, (type) -> type.id && type.id != 7 #excluding "Default" and "Fake User"
		appliedFilter = null

		$scope.onFilterApply = (query) ->
			query.team_id = query.team_id || 'all'
			appliedFilter = query
			getReport query

		getReport = (query) ->
			ActivityReport.get query, (report_data) ->
				$scope.user_activities = report_data.user_activities
				$scope.total_activities = report_data.total_activity_report
				$scope.initReport()

		Team.all(all_teams: true).then (teams) ->
			$scope.teams = teams

		ActivityType.all().then (activityTypes) ->
			$scope.types = angular.copy(activityTypes)
			_.each $scope.types, (type) ->
				$scope.typeIds[type.name] = type.id

		$scope.initReport = ->
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

		$scope.showActivityDetailModal = (memberId, typeId) ->
			$scope.modalInstance = $modal.open
				templateUrl: 'modals/activity_detail_table.html'
				size: 'xl'
				controller: 'ActivityDetailReportsController'
				backdrop: 'static'
				keyboard: false
				resolve:
					activitySummaryParams: -> {
						memberId
						typeId
						start_date: appliedFilter.start_date
						end_date: appliedFilter.end_date
					}

		$scope.exportReports = ->
			url = '/api/reports.csv'
			$window.open url + '?' + $httpParamSerializer appliedFilter
			return
	]
