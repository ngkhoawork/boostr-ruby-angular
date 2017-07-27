app.directive 'fixedTableHeader',
	['$window', '$compile', '$timeout'
	( $window,   $compile,   $timeout ) ->
		restrict: 'A'
		scope: false
		link: ($scope, element, attrs) ->
			mainClass = 'fixed-table-header'
			window = angular.element($window)
			table = angular.element(element)
			container = table.parent()
			thead = table.find('thead')
			header = thead.children()
			headerCopy = header.clone()
			thead.append(headerCopy)
			header.addClass mainClass
			container.css 'position', 'relative'

			updateHeaderCopy = ->
				previousCopy = headerCopy
				headerCopy = header.clone().removeClass mainClass
#				headerCopy.children().each -> angular.element(this).css('min-width', 0)
				previousCopy.replaceWith headerCopy

			window.scroll ->
				offsetTop = table.offset().top
				if window.scrollTop() > offsetTop
					header.addClass 'fixed'
					header.css 'top', window.scrollTop() - offsetTop
				else
					header.removeClass 'fixed'
					header.css 'top', 0

			watcher = ->
				$timeout ->
					updateHeaderCopy()
					ths = header.find('th')
					headerCopy.find('th').each (i) ->
						width = angular.element(this).outerWidth()
						angular.element(ths[i]).css('min-width', width)

			watchers = $scope.$eval attrs.watch
			_.each watchers, (w) -> $scope.$watch w, watcher

	]