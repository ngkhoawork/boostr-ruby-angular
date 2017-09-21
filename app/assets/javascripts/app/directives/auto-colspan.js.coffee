app.directive 'autoColspan', ->
	restrict: 'C'
	scope: false
	link: ($scope, element, attrs) ->
		td = angular.element(element)
		length = td.parent().prev().children().length
		td.attr 'colspan', length


