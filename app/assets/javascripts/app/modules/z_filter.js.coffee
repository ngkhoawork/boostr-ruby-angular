(->
	angular.module('zFilterModule', [])

	.controller 'ZFilterController', ['$scope', ($scope) ->
		$scope.test = 20
		$scope.isFilterApplied = false
		this.query = {}
		this.test = 30
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
				$scope.emptyFilter = {id: null, name: 'All'}
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
						$scope.default = $scope.emptyFilter
						updateSelection = (item) ->
							$scope.selected = item
							_.each $scope.saveAs, (valueKey, queryKey) ->
								ctrl.setQuery queryKey, item[valueKey]

				(resetFilter = ->
					$scope.selected = angular.copy $scope.default
				)()
				$scope.setFilter = (item) ->
					updateSelection(item)
					if _.isFunction $scope.onChange then $scope.onChange(item)

				$scope.isFinite = _.isFinite
				$scope.$watch 'data', (newData) ->
					if !_.findWhere newData, {id: $scope.selected && $scope.selected.id} then resetFilter()
				$scope.$on 'resetFilter', ->
					resetFilter()

)()