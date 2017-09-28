@app.controller 'GmailExtensionController',
['$scope', '$window', '$modal'
( $scope,   $window,   $modal ) ->

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
						$window.parent.parent.postMessage {
							eval: 'onDealModelClose()'
						}, '*'
					onSuccess: ->
						$window.parent.parent.postMessage {
							eval: 'onDealCreateSuccess()'
						}, '*'
	$window.addEventListener 'message', (e) ->
		if e.origin is 'https://mail.google.com'
			$scope.$eval e.data.eval if e.data.eval

#	$scope.showNewDealModal()
]