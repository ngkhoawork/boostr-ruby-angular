@app.controller 'SettingsActivityTypesController',
	['$scope', '$modal', '$filter', 'ActivityType', 'ActivityTypeIconsList'
	( $scope,   $modal,   $filter,   ActivityType,   ActivityTypeIconsList ) ->

		$scope.activityTypes = []
		positions = {}
		iconsList = ActivityTypeIconsList

		(getActivityTypes = ->
			ActivityType.all(inactive: true).then (data) ->
				$scope.activityTypes = $filter('orderBy')(data, ['position', 'name'])
				positions = getPositions()
				syncIconsList()
		)()

		$scope.updateActivityType = (type) ->
			ActivityType.update(type, true).then (data) ->
				_.extend type, data

		$scope.deleteActivityType = (type) ->
			if confirm("Are you sure you want to delete #{type.name}?")
				ActivityType.delete(type)

		$scope.onTypeMoved = (typeIndex) ->
			$scope.activityTypes.splice(typeIndex, 1)
			newPositions = getPositions()
			if _.isEqual positions, newPositions then return
			changes = _.omit positions, (val, key) -> newPositions[key] == val
			updatePositions(changes)
			positions = newPositions

		$scope.showActivityTypeModal = (activityType) ->
			$scope.modalInstance = $modal.open
				templateUrl: 'modals/activity_type_form.html'
				size: 'md'
				controller: 'ActivityTypeModalController'
				backdrop: 'static'
				keyboard: false
				resolve:
					activityType: -> angular.copy activityType
					iconsList: -> iconsList

		$scope.$on 'updated_activity_types', getActivityTypes

		getPositions = ->
			_positions = {}
			_.each $scope.activityTypes, (t, i) -> _positions[t.id] = i + 1
			_positions

		syncIconsList = ->
			usedIcons = _.pluck($scope.activityTypes, 'css_class')
			iconsList = _.difference ActivityTypeIconsList, usedIcons

		updatePositions = (changes) ->
			ActivityType.updatePositions(activity_types_position: changes)


#		$scope.showActivityTypeModal()

	]
