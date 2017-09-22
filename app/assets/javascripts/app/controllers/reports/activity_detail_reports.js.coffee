@app.controller 'ActivityDetailReportsController',
	['$scope', '$document', '$modal', '$modalInstance', '$routeParams', '$httpParamSerializer', '$location', '$window', '$sce', 'Team', 'Seller', 'Activity', 'ActivityType', 'activitySummaryParams'
	( $scope,   $document,   $modal,   $modalInstance,   $routeParams,   $httpParamSerializer,   $location,   $window,   $sce,   Team,   Seller,   Activity,   ActivityType,   activitySummaryParams ) ->

		$scope.sortType = 'happened_at'
		$scope.sortReverse = true
		$scope.teams = []
		$scope.members = []
		$scope.activityTypes = []

		emptyFilter = $scope.emptyFilter = {id: null, name: 'All'}
		appliedFilter = null
		defaultFilter =
			team: emptyFilter
			member: emptyFilter
			type: emptyFilter
			date:
				startDate: null
				endDate: null

		$scope.filter = angular.copy defaultFilter

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

		getQuery = (isPrev) ->
			f = if isPrev then appliedFilter else $scope.filter
			query = {filter: 'detail'}
			query.team_id = f.team.id || 'all'
			query.member_id = f.member.id if f.member.id
			query.activity_type_id = f.type.id if f.type.id
			if f.date.startDate && f.date.endDate
				query.start_date = f.date.startDate.format('YYYY-MM-DD')
				query.end_date = f.date.endDate.format('YYYY-MM-DD')
			query

		getReport = (query) ->
			Activity.all(query).then (activities) ->
				$scope.activities = activities
#			delete query.filter
#			$location.search query

		if activitySummaryParams
			((p) ->
				$scope.filter =
					team: {id: 'all'}
					member: {id: p.memberId}
					type: {id: p.typeId}
					date: p.date
				$scope.applyFilter()
			)(activitySummaryParams)

#		if $routeParams.start_date && $routeParams.end_date
#			$scope.filter.date =
#				startDate: moment($routeParams.start_date)
#				endDate: moment($routeParams.end_date)


		fetchTeamMembers = (teamId, init) ->
			Seller.query({id: teamId || 'all'}).$promise.then (members) ->
				$scope.members = members
#				if $routeParams.member_id && init
#					member = _.findWhere $scope.members, {id: Number $routeParams.member_id}
#					$scope.setFilter('member', member) if member


		$scope.init = ->
			Team.all(all_teams: true).then (teams) ->
				$scope.teams = teams
				$scope.teams.unshift({
					id: 'all',
					name: 'All'
				})
#				if $routeParams.team_id
#					(searchAndSetTeam = (teams, teamId) ->
#						for team in teams
#							if team.id is teamId then return $scope.setFilter('team', team)
#							if team.children && team.children.length then searchAndSetTeam team.children, teamId
#					)($scope.teams, Number $routeParams.team_id)
			fetchTeamMembers('all', true)

			ActivityType.all().then (activityTypes) ->
				$scope.activityTypes = angular.copy(activityTypes)
#				if $routeParams.activity_type_id
#					type = _.findWhere $scope.activityTypes, {id: Number $routeParams.activity_type_id}
#					$scope.setFilter('type', type) if type

		$scope.init()

		$scope.$watch 'filter.team', (team) ->
			if team.id then $scope.setFilter('member', emptyFilter)
			fetchTeamMembers(team.id || 'all')

		$scope.exportReports = ->
			url = '/api/activities.csv'
			$window.open url + '?' + $httpParamSerializer getQuery()
			return

		$scope.changeSortType = (sortType) ->
			if sortType == $scope.sortType
				$scope.sortReverse = !$scope.sortReverse
			else
				$scope.sortType = sortType
				$scope.sortReverse = false

		$scope.getHtml = (html) -> $sce.trustAsHtml(html)

		$scope.cancel = -> $modalInstance.close()

		$scope.showEmailsModal = (activity, e) ->
			e.stopPropagation()
			$scope.modalInstance = $modal.open
				templateUrl: 'modals/activity_emails.html'
				size: 'lg'
				controller: 'ActivityEmailsController'
				backdrop: 'static'
				keyboard: false
				resolve:
					activity: ->
						activity

		$scope.showActivityEditModal = (activity) ->
			$scope.modalInstance = $modal.open
				templateUrl: 'modals/activity_new_form.html'
				size: 'md'
				controller: 'ActivityNewController'
				backdrop: 'static'
				keyboard: false
				resolve:
					activity: -> activity
					options: -> null


		$scope.$on 'updated_activities', ->
			getReport getQuery(true)
	]
