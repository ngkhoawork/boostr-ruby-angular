@directives.directive 'zDdAr', ['$window', ($window) ->
	restrict: 'CA'
	link: (scope, el) ->
		el.bind 'mouseover', (e) ->
			dropdown = el.parent()
			dropdownMenu = dropdown.find('.dropdown-menu')
			ddmStyles = dropdownMenu.attr 'style'
			dropdownMenu.css
				visibility: 'hidden'
				display: 'block'
			ddmWidth = dropdownMenu.outerWidth()
			dropdownMenu.attr 'style', ddmStyles || ''
			window = angular.element($window)
			rightOffset = window.width() - (dropdown.offset().left + ddmWidth)
			dropdownMenu.toggleClass('dropdown-menu-right', rightOffset <= 0)
]

