@app.controller 'ActivityDetailReportsController',
	['$scope', '$modal', '$modalInstance', '$httpParamSerializer', '$window', '$sce', 'Team', 'Seller', 'Activity', 'ActivityType', 'activitySummaryParams', 'CustomFieldNames'
	( $scope,   $modal,   $modalInstance,   $httpParamSerializer,   $window,   $sce,   Team,   Seller,   Activity,   ActivityType,   activitySummaryParams, CustomFieldNames ) ->

		$scope.teams = []
		$scope.sellers = []
		$scope.activityTypes = []

		appliedFilter = null

		$scope.onFilterApply = (query) ->
			query.filter = 'detail'
			appliedFilter = query
			getReport query

		getReport = (query) ->
			Activity.all(query).then (activities) ->
				$scope.activities = activities

		if activitySummaryParams
			((p) ->
				query = {filter: 'detail'}
				query.team_id = 'all'
				query.member_id = p.memberId
				query.activity_type_id = p.typeId
				if p.start_date && p.end_date
					query.start_date = p.start_date
					query.end_date = p.end_date
				getReport query
			)(activitySummaryParams)

		($scope.updateSellers = (team) ->
			Seller.query({id: (team && team.id) || 'all'}).$promise.then (sellers) ->
				$scope.sellers = sellers
		)()

		Team.all(all_teams: true).then (teams) ->
			$scope.teams = teams

  CustomFieldNames.all({subject_type: 'activity', show_on_modal: true}).then (customFieldNames) ->
      $scope.customFieldNames = customFieldNames

		ActivityType.all().then (activityTypes) ->
			$scope.activityTypes = angular.copy(activityTypes)

		$scope.getHtml = (html) -> $sce.trustAsHtml(html)

		$scope.cancel = -> $modalInstance.close()

		$scope.showEmailsModal = (activity, e) ->
			e.stopPropagation()
			$scope.modalInstance = $modal.open
				templateUrl: 'modals/activity_emails.html'
				size: 'email'
				controller: 'ActivityEmailsController'
				backdrop: 'static'
				keyboard: false
				resolve:
					activity: ->
						activity

		$scope.isTextHasTags = (str) -> /<[a-z][\s\S]*>/i.test(str)

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
			getReport appliedFilter

		$scope.$on 'openContactModal', ->
			$modal.open
				templateUrl: 'modals/contact_form.html'
				controller: 'ContactsNewController'
				size: 'md'
				backdrop: 'static'
				resolve:
					contact: -> {}
					options: -> {}

		$scope.$on 'dashboard.openAccountModal', ->
			$modal.open
				templateUrl: 'modals/client_form.html'
				controller: 'AccountsNewController'
				size: 'md'
				backdrop: 'static'
				resolve:
					client: -> {}
					options: -> {}

		$scope.exportReports = ->
			url = '/api/activities.csv'
			$window.open url + '?' + $httpParamSerializer appliedFilter
			return
	]
