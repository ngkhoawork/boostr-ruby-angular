@directives.directive 'zToggle', ->
	restrict: 'E'
	replace: true
	scope:
		toggleValue: '=ngModel'
	template: '<div class="z-toggle toggle-active"><span></span></div>'
	link: (scope, el) ->
		el.toggleClass('toggle-active', scope.toggleValue)
		el.bind 'click', ->
			scope.toggleValue = !scope.toggleValue
			el.toggleClass('toggle-active', scope.toggleValue)
			scope.$apply()


