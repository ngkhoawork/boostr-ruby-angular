(->
	angular.module('zFilterModule', [])

	.controller 'ZFilterController', ['$scope', 'localStorageService', ($scope, LS) ->
		reportName = _.last(window.location.pathname.split('/'))
		$scope.recentQueries = LS.get(reportName)
		$scope.isFilterApplied = false
		this.query = {}
		this.loadedQuery = $scope.recentQueries && $scope.recentQueries[0]
		console.log this.query
		this.saveRecentQuery = ->
			$scope.recentQueries = _.without $scope.recentQueries, this.query
			$scope.recentQueries.unshift(this.query)
			if $scope.recentQueries.length > 5 then $scope.recentQueries.pop()
			LS.set(reportName, $scope.recentQueries)
		this.savedQuery = null
		this.setQuery = (key, value) ->
			this.query[key] = value
			if !value then delete this.query[key]
			this.checkApplied()
		this.checkApplied = ->
			$scope.isFilterApplied = angular.equals this.query, this.savedQuery
		return this
	]

	.directive 'zFilter', ->
		restrict: 'E'
		replace: true
		transclude: true
		scope:
			onApply: '='
		controller: 'ZFilterController'
		templateUrl: 'modules/z_filter.html'
		link: ($scope, el, attrs, ctrl, trans) ->
			trans (clone) -> el.find('.element-to-replace').replaceWith(clone)
			$scope.applyFilter = ->
				$scope.onApply(ctrl.query)
				ctrl.savedQuery = angular.copy ctrl.query
				ctrl.saveRecentQuery()
				ctrl.checkApplied()
			$scope.resetFilter = ->
				ctrl.query = {}
				ctrl.checkApplied()
				$scope.$broadcast 'resetFilter'

	.directive 'zFilterField', ->
		restrict: 'E'
		replace: true
		transclude: true
		require: '^zFilter'
		scope:
			data: '='
			saveAs: '='
			type: '@'
			onChange: '='
		templateUrl: 'modules/z_filter_field.html'
		compile: (el, attrs) ->
			attrs.type = attrs.type || 'list' #default type
			post: ($scope, el, attrs, ctrl, trans) ->
				trans (clone) -> el.find('.element-to-replace').replaceWith(clone)
				$scope.isAll = !(attrs.isAll == 'false')
				switch $scope.type
					when 'daterange'
						$scope.default =
							date:
								startDate: null
								endDate: null
							dateString: ''

						$scope.datePicker =
							savedDate:
								startDate: null
								endDate: null
							toString: ->
								d = $scope.selected.date
								if !d.startDate || !d.endDate then return false
								d.startDate.format('MMM D, YY') + ' - ' + d.endDate.format('MMM D, YY')
							apply: ->
								d = $scope.selected.date
								if d.startDate && d.endDate
									$scope.datePicker.savedDate = angular.copy d
								else
									d.startDate = $scope.datePicker.savedDate.startDate
									d.endDate = $scope.datePicker.savedDate.endDate
								$scope.selected.dateString = $scope.datePicker.toString()
								$scope.setFilter(
									startDate: d.startDate && d.startDate.format('YYYY-MM-DD')
									endDate: d.endDate && d.endDate.format('YYYY-MM-DD')
								)

						updateSelection = (item) ->
							_.each $scope.saveAs, (valueKey, queryKey) ->
								ctrl.setQuery queryKey, item[valueKey]
					when 'stage'
						$scope.default = []
						$scope.isStageSelected = (id) ->
							_.findWhere $scope.selected, id: id
						updateSelection = (item) ->
							if item then $scope.selected.push item else $scope.selected = []
							_.each $scope.saveAs, (valueKey, queryKey) ->
								value = _.pluck($scope.selected, valueKey) if $scope.selected.length
								ctrl.setQuery queryKey, value
						$scope.removeFilter = (item) ->
							$scope.selected = _.reject $scope.selected, (v) -> v.id == item.id
							_.each $scope.saveAs, (valueKey, queryKey) ->
								value = _.pluck($scope.selected, valueKey) if $scope.selected.length
								ctrl.setQuery queryKey, value
					else
						$scope.default = null
						updateSelection = (item) ->
							$scope.selected = item
							_.each $scope.saveAs, (valueKey, queryKey) ->
								ctrl.setQuery queryKey, item && item[valueKey]

				$scope.setFilter = (item) ->
					updateSelection(item)
					if _.isFunction $scope.onChange then $scope.onChange(item)
				isItemLoaded = false
				$scope.isFinite = _.isFinite
				$scope.$watch 'data', (data, prevData) ->
					if !_.findWhere data, {id: $scope.selected && $scope.selected.id} then resetFilter()
					if !isItemLoaded
						_.each $scope.saveAs, (valueKey, queryKey) ->
							loadedValue = ctrl.loadedQuery[queryKey]
							if _.isArray loadedValue
								_.each data, (item) ->
									if _.contains loadedValue, item[valueKey]
										$scope.setFilter item
										isItemLoaded = true
							else
								findBy = {}
								findBy[valueKey] = loadedValue
								item = _.findWhere data, findBy
								if item
									$scope.setFilter item
									isItemLoaded = true
				$scope.$on 'resetFilter', ->
					resetFilter()

				(resetFilter = ()->
					$scope.selected = angular.copy $scope.default
					_.each $scope.saveAs, (valueKey, queryKey) ->
						ctrl.setQuery queryKey, null
				)()

)()