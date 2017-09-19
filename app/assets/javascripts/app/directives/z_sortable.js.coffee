@directives.directive 'zSortable',
	['$timeout', ( $timeout ) ->
		restrict: 'CA'
		scope:
			by: '@'
			byMany: '=by'

		link: (scope, el, attrs) ->
			arrow = angular.element('<i class="fa fa-caret-down"></i>')
			arrow.css 'visibility', 'hidden'
			el.append(arrow)
			if !_.isUndefined attrs.default
				$timeout ->
					scope.$parent.setSort(scope.byMany || scope.by, arrow)
			el.bind 'click', ->
				scope.$parent.setSort(scope.byMany || scope.by, arrow)
	]