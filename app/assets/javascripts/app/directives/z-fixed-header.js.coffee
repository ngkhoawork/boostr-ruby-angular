app.directive 'zFixedHeader',
	['$window', '$document', '$compile', '$timeout'
	( $window,   $document,   $compile,   $timeout ) ->
		restrict: 'A'
		link: ($scope, element, attrs) ->
			mainClass = 'z-fixed-header'
			window = angular.element($window)
			header = angular.element(element)
			table = header.closest('table')
			container = table.parent()
			headerCopy = header.clone()
			header.after(headerCopy)
			header.addClass mainClass
			container.css 'position', 'relative'
			maxTop = 0

			updateHeaderCopy = ->
				previousCopy = headerCopy
				headerCopy = header.clone().removeClass mainClass
				headerCopy.children().each -> angular.element(this).css('min-width', '')
				previousCopy.replaceWith headerCopy

			scroll = ->
				offsetTop = table.offset().top - _fixedHeaderHeight
				if window.scrollTop() > offsetTop
					header.addClass 'fixed'
					top = window.scrollTop() - offsetTop
					header.css 'top', if top > maxTop then maxTop else top
				else
					header.removeClass 'fixed'
					header.css 'top', 0

			$document.bind 'scroll', scroll
			$scope.$on '$destroy', -> $document.unbind 'scroll', scroll

			watcher = ->
				$timeout ->
					maxTop = table.outerHeight() - header.outerHeight()
					updateHeaderCopy()
					ths = header.find('th')
					headerCopy.find('th').each (i) ->
						width = angular.element(this).outerWidth()
						angular.element(ths[i]).css('min-width', width)

			watch = $scope.$eval attrs.watch
			if _.isArray watch
				$scope.$watchGroup watch, watcher
			else
				$scope.$watch watch, watcher

	]