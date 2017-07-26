app.directive 'fixedTableHeader',
	['$window', '$compile', '$timeout'
	( $window,   $compile,   $timeout ) ->
		restrict: 'A'
		scope: false
		link: ($scope, element, attrs) ->
			console.time()
			window = angular.element($window)
			source = angular.element(element)
			sourceContainer = source.parent()
			sourceHeader = source.find('thead')
			headerContainer = angular.element('<div class="fixed-table-header-wrap"></div>')
			header = source.clone()
			header.removeAttr 'fixed-table-header'
			header.find('tbody').remove()
#			compiledHeader = $compile(header)($scope)
			headerContainer.append(header)
			sourceContainer.prepend(headerContainer)

			updateHeader = ->
				thead = source.find('thead').clone()
				thead.find('[ng-repeat]').removeAttr 'ng-repeat'
				$compile(thead)($scope)
				headerContainer.find('thead').replaceWith thead
#				headerContainer.find('thead').replaceWith thead
#				headerContainer.empty()
#				header = source.clone()
#				header.removeAttr 'fixed-table-header'
#				header.find('tbody').remove()
#				compiledHeader = $compile(header)($scope)
#				headerContainer.append(compiledHeader)
#				sourceContainer.prepend(headerContainer)


			updateWidth = ->
				headerContainer.width sourceContainer.width()

			watcher = (newValue) ->
				console.log newValue
				console.time('WATCH')
				$timeout ->
					updateWidth()
					updateHeader()
					sourceThs = source.find('th')
					headerThs = header.find('th')
					sourceThs.each (i) ->
						sourceWidth = angular.element(this).outerWidth()
						angular.element(headerThs[i]).css('min-width', sourceWidth)
				console.timeEnd('WATCH')

			values = $scope.$eval attrs.watch
			_.each values, (value) -> $scope.$watch value, watcher


			sourceContainer.scroll ->
				leftOffset = angular.element(this).scrollLeft()
				headerContainer.scrollLeft(leftOffset)

			window.scroll ->
				offsetTop = sourceHeader.offset().top
				height = sourceHeader.outerHeight()
				if window.scrollTop() > offsetTop
					headerContainer.addClass 'visible'
				else
					headerContainer.removeClass 'visible'

			window.on 'resize', updateWidth
			$scope.$on '$destroy', -> window.off 'resize', updateWidth
			console.timeEnd()
	]