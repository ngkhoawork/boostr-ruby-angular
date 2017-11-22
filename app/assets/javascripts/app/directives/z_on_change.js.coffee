@directives.directive 'zOnChange', ->
	restrict: 'A'
	link: (scope, element, attrs) ->
		onChangeHandler = scope.$eval(attrs.zOnChange)
		element.on 'change', onChangeHandler
		element.on '$destroy', ->
			element.off()
			return
		return
