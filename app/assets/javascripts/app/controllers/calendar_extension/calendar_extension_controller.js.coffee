@app.controller 'CalendarExtensionController',
['$scope', '$rootScope', '$window', '$modal', 'Activity', 'ActivityType'
( $scope,   $rootScope,   $window,   $modal,   Activity,   ActivityType ) ->

	angular.element('body').css
		backgroundColor: 'transparent'

	closeExtensionModal = (params) ->
		$window.parent.postMessage {expression: 'onModelClose', params}, '*'

	$scope.openContactModal = ->
		$scope.populateContact = true
		modalInstance = $modal.open
			templateUrl: 'modals/contact_form.html'
			size: 'md'
			controller: 'ContactsNewController'
			backdrop: 'static'
			keyboard: false
			resolve:
				contact: ->
					{}

		modalInstance.result.then (contact) ->
			closeExtensionModal({type: 'Contact', id: contact && contact.id})
		, (err) ->
			closeExtensionModal()

	$scope.openAccountModal = ->
		modalInstance = $modal.open
			templateUrl: 'modals/client_form.html'
			size: 'md'
			controller: 'AccountsNewController'
			backdrop: 'static'
			keyboard: false
			resolve:
				client: ->
					{}

		modalInstance.result.then (account) ->
			console.log account
			closeExtensionModal({type: 'Account', id: account && account.id})
		, (err) ->
			closeExtensionModal()

	$scope.$on 'openContactModal', ->
		$scope.openContactModal()

	$scope.$on 'dashboard.openAccountModal', ->
		$scope.openAccountModal()

	$window.addEventListener 'message', (e) ->
		if e.origin is 'https://calendar.google.com'
			expression = $scope.$eval(e.data.expression) if e.data.expression
			expression(e.data.params) if _.isFunction expression

	$window.parent.postMessage {expression: 'onBoostrLoaded'}, '*'

]