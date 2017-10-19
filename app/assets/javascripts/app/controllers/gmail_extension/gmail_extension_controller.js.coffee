@app.controller 'GmailExtensionController',
['$scope', '$rootScope', '$window', '$modal'
( $scope,   $rootScope,   $window,   $modal ) ->

	angular.element('body').css
		backgroundColor: 'transparent'

	$scope.showNewDealModal = ->
		$scope.modalInstance = $modal.open
			templateUrl: 'modals/deal_form.html'
			size: 'md'
			controller: 'DealsNewController'
			backdrop: 'static'
			keyboard: false
			resolve:
				deal: -> {}
				options: ->
					type: 'gmail'
					onCancel: ->
						$window.parent.postMessage {expression: 'onModelClose'}, '*'
					onSuccess: ->
						$window.parent.postMessage {expression: 'onDealCreateSuccess'}, '*'

	$scope.showNewActivityModal = (data) ->
		$scope.modalInstance = $modal.open
			templateUrl: 'modals/activity_new_form.html'
			size: 'md'
			controller: 'ActivityNewController'
			backdrop: 'static'
			keyboard: false
			resolve:
				activity: ->
					null
				options: ->
					type: 'gmail'
					data: data
					onCancel: ->
						$window.parent.postMessage {expression: 'onModelClose'}, '*'
					onSuccess: ->
						$window.parent.postMessage {expression: 'onActivityCreateSuccess'}, '*'

#	$scope.showNewActivityModal()

	$window.addEventListener 'message', (e) ->
		if e.origin is 'https://mail.google.com'
			expression = $scope.$eval(e.data.expression) if e.data.expression
			expression(e.data.params) if _.isFunction expression

	$window.parent.postMessage {expression: 'onBoostrLoaded'}, '*'

]