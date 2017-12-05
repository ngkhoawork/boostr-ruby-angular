@app.controller 'GmailExtensionController',
['$scope', '$rootScope', '$window', '$modal', 'Activity', 'ActivityType'
( $scope,   $rootScope,   $window,   $modal,   Activity,   ActivityType ) ->

	angular.element('body').css
		backgroundColor: 'transparent'

	closeExtensionModal = (params) ->
		$window.parent.postMessage {expression: 'onModelClose', params}, '*'

	createActivity = (activityData, deal) ->
		return if !deal || !deal.id
		activity = _.omit activityData, 'contacts', 'guests'
		activity.deal_id = deal.id
		activity.client_id = deal.advertiser_id if deal.advertiser_id
		activity.agency_id = deal.agency_id if deal.agency_id
		ActivityType.all().then (activityTypes) ->
			type = _.findWhere activityTypes, {name: 'Email'}
			return if !type
			activity.activity_type_id = type.id
			activity.activity_type_name = type.name
			Activity.create({
				activity
				guests: activityData.guests
			})

	$scope.showNewDealModal = (activityData) ->
		modalInstance = $modal.open
			templateUrl: 'modals/deal_form.html'
			size: 'md'
			controller: 'DealsNewController'
			backdrop: 'static'
			keyboard: true
			resolve:
				deal: -> {}
				options: ->
					type: 'gmail'

		modalInstance.result.then (deal) ->
			createActivity(activityData, deal)
			closeExtensionModal({type: 'Deal', id: deal && deal.id})
		, (err) ->
			closeExtensionModal()

	$scope.showNewActivityModal = (activityData) ->
		modalInstance = $modal.open
			templateUrl: 'modals/activity_new_form.html'
			size: 'md'
			controller: 'ActivityNewController'
			backdrop: 'static'
			keyboard: true
			resolve:
				activity: ->
					null
				options: ->
					type: 'gmail'
					data: activityData

		modalInstance.result.then (activity) ->
			closeExtensionModal({type: 'Activity', id: activity && activity.id})
		, (err) ->
			closeExtensionModal()

	$scope.openContactModal = ->
		$scope.populateContact = true
		$scope.modalInstance = $modal.open
			templateUrl: 'modals/contact_form.html'
			size: 'md'
			controller: 'ContactsNewController'
			backdrop: 'static'
			keyboard: false
			resolve:
				contact: ->
					{}

	$scope.openAccountModal = ->
		$scope.modalInstance = $modal.open
			templateUrl: 'modals/client_form.html'
			size: 'md'
			controller: 'AccountsNewController'
			backdrop: 'static'
			keyboard: false
			resolve:
				client: ->
					{}

	$scope.$on 'openContactModal', ->
		$scope.openContactModal()

	$scope.$on 'dashboard.openAccountModal', ->
		$scope.openAccountModal()

	$window.addEventListener 'message', (e) ->
		if e.origin is 'https://mail.google.com'
			expression = $scope.$eval(e.data.expression) if e.data.expression
			expression(e.data.params) if _.isFunction expression

	$window.parent.postMessage {expression: 'onBoostrLoaded'}, '*'

]