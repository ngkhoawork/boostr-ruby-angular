app.directive 'autoColspan', ->
	restrict: 'C'
	scope: false
	link: ($scope, element) ->
		prevEl = element.parent().prev()
		if prevEl.length
			max = prevEl.children().length
		else
			table = element.closest('table')
			trs = table.find('thead').first().children()
			max = 0
			trs.each ->
				len = angular.element(this).children().length
				max = len if len > max
		element.attr 'colspan', max