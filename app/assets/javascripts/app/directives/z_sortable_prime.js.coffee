@directives.directive 'zSortablePrime', ->
	restrict: 'CA'
	scope: true
	link: (scope, el, attrs) ->
		scope.$parent.zSort = {} if !scope.$parent.zSort
		zSort =
			by: ''
			rev: false
			set: (key) ->
				if this.by == key
					this.rev = !this.rev
				else
					this.by = key
					this.rev = false
		if attrs.sortName
			scope.$parent.zSort[attrs.sortName] = zSort
		else
			scope.$parent.zSort = zSort

		scope.setSort = (key, arrow) ->
			zSort.set(key)
			el.find('i[class*="fa-caret"]').css 'visibility', 'hidden'
			arrow.css 'visibility', 'visible'
			arrow.toggleClass('fa-caret-up', zSort.rev)
			arrow.toggleClass('fa-caret-down', !zSort.rev)
			scope.$parent.$apply()
