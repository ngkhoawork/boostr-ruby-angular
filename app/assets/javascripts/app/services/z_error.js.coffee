@service.factory 'zError', [
	'$document', '$timeout'
	($document,   $timeout) ->
		(selector, error, delay = 5000) ->
			target = angular.element(selector)
			el = angular.element('<div class="z-error"></div>')
			el.html(error)
			angular.element($document[0].body).append el
			$timeout ->
				el.offset
					top: target.offset().top - el.outerHeight() - 10
					left: target.offset().left - el.outerWidth() / 2 + target.outerWidth() / 2
				el.addClass 'visible'
			$timeout (-> el.css(opacity: 0); $timeout (-> el.remove()), 1000), delay


]