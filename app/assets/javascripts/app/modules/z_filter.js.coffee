(->
	angular.module('zFilterModule', [])

	.controller 'ZFilterController', ['$scope', 'localStorageService', 'ReportQuery', ($scope, LS, ReportQuery) ->
		this.reportName = _.last(window.location.pathname.split('/'))
		$scope.recentQueries = LS.get(this.reportName)
		$scope.savedQueries = []
		(getSavedQueries = ->
			ReportQuery.get(query_type: this.reportName).then (data) ->
				$scope.savedQueries = _.map data, (q) -> q.filter_params = JSON.parse(q.filter_params); q
		)()
		$scope.isFilterApplied = false
		$scope.$on 'report_queries_updated', -> getSavedQueries()
		this.query = {}
		this.loadedQuery = $scope.recentQueries && $scope.recentQueries[0]
		this.saveRecentQuery = ->
			if _.isEmpty this.query then return
			$scope.recentQueries = _.filter $scope.recentQueries, (q) =>
				!angular.equals this.query, q
			$scope.recentQueries.unshift(angular.copy this.query)
			if $scope.recentQueries.length > 5 then $scope.recentQueries.pop()
			LS.set(this.reportName, $scope.recentQueries)
		this.saveQuery = (query) ->
#			$scope.savedQueries.unshift item
			query.filter_params = angular.toJson query.filter_params
			if query.id
				ReportQuery.update(id: query.id, filter_query: query)
			else
				ReportQuery.save(filter_query: query)
		this.deleteQuery = (query) ->
			ReportQuery.delete(id: query.id)
		this.appliedQuery = null
		this.setQuery = (key, value) ->
			this.query[key] = value
			if !value then delete this.query[key]
			this.checkApplied()
		this.checkApplied = ->
			$scope.isFilterApplied = angular.equals this.query, this.appliedQuery
		return this
	]

	.directive 'zFilter', ['$timeout', ($timeout) ->
		restrict: 'E'
		replace: true
		transclude: true
		scope:
			onApply: '='
		controller: 'ZFilterController'
		templateUrl: 'modules/z_filter.html'
		link: ($scope, el, attrs, ctrl, trans) ->
			trans (clone) -> el.find('.element-to-replace').replaceWith(clone)
			$scope.isQueryDropdownOpen = false
			$scope.isQueryFormOnEdit = true
			emptySavedQueryForm =
				name: ''
				query_type: ctrl.reportName
				filter_params: {}
				default: false
				global: false
			(resetQueryForm = ->
				$scope.isQueryFormOnEdit = false
				$scope.savedQueryForm = angular.copy emptySavedQueryForm
			)()
			$scope.onQueryDropdownToggle = (isOpen) ->
				if !isOpen then resetQueryForm()
			$scope.applyFilter = ->
				$scope.onApply(ctrl.query)
				ctrl.appliedQuery = angular.copy ctrl.query
				ctrl.saveRecentQuery()
				ctrl.checkApplied()
			$scope.saveQuery = (e, query) ->
				e.stopPropagation()
				$scope.isQueryFormOnEdit = true
				$scope.savedQueryForm.filter_params = angular.toJson query
				$timeout -> angular.element('.query-name-input').focus()
			$scope.submitQueryForm = ->
				ctrl.saveQuery($scope.savedQueryForm)
				resetQueryForm()
			$scope.editQuery = (e, query) ->
				e.stopPropagation()
				$scope.isQueryFormOnEdit = true
				$scope.savedQueryForm = angular.copy query
			$scope.deleteQuery = (e, query) ->
				e.stopPropagation()
				ctrl.deleteQuery(query)
			$scope.cancelQueryForm = ->
				resetQueryForm()
			$scope.loadQuery = (query) ->
				ctrl.loadedQuery = query
				$scope.$broadcast 'loadQuery', query
			$scope.resetFilter = ->
				ctrl.query = {}
				ctrl.loadedQuery = {}
				ctrl.checkApplied()
				$scope.$broadcast 'resetFilter'
			$scope.objLength = (obj) -> _.keys(obj).length
			$scope.compareQueries = (query) -> angular.equals query, ctrl.query
	]
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
			default: '='
		templateUrl: 'modules/z_filter_field.html'
		compile: (el, attrs) ->
			attrs.type = attrs.type || 'list' #default type
			post: ($scope, el, attrs, ctrl, trans) ->
				trans (clone) -> el.find('.element-to-replace').replaceWith(clone)
				$scope.isAll = !(attrs.isAll == 'false')
				isItemLoaded = false

				switch $scope.type
					when 'daterange' #============================================================================
						$scope.defaultFilter =
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
								$scope.setFilter d
						updateSelection = (item) ->
							$scope.selected.date = item
							$scope.selected.dateString = $scope.datePicker.toString()
							item =
								startDate: item.startDate && item.startDate.format('YYYY-MM-DD')
								endDate: item.endDate && item.endDate.format('YYYY-MM-DD')
							_.each $scope.saveAs, (valueKey, queryKey) ->
								ctrl.setQuery queryKey, item[valueKey]
						loadFromQuery = (query, callback) ->
							if !query then return
							$scope.selected = date:
								startDate: null
								endDate: null
							$scope.selected.dateString = $scope.datePicker.toString()
							_.each $scope.saveAs, (valueKey, queryKey) ->
								ctrl.setQuery queryKey, null
							date = angular.copy $scope.selected.date
							_.each $scope.saveAs, (valueKey, queryKey) ->
								loadedDate = moment(query[queryKey] || null)
								if loadedDate.isValid() then date[valueKey] = loadedDate
							if date.startDate && date.endDate
								$scope.datePicker.savedDate = angular.copy date
								$scope.setFilter date
								callback() if _.isFunction callback
						resetToDefault = ->
							d = $scope.defaultFilter.date
							if d && d.startDate && d.endDate
								$scope.setFilter(d)
							else
								$scope.selected = angular.copy $scope.defaultFilter
								$scope.selected.dateString = $scope.datePicker.toString()
								_.each $scope.saveAs, (valueKey, queryKey) ->
									ctrl.setQuery queryKey, null
					when 'stage' #================================================================================
						$scope.defaultFilter = []
						$scope.isStageSelected = (id) ->
							_.findWhere $scope.selected, id: id
						updateSelection = (item) ->
							if item then $scope.selected.push item else $scope.selected = []
							_.each $scope.saveAs, (valueKey, queryKey) ->
								value = _.pluck($scope.selected, valueKey) if $scope.selected.length
								ctrl.setQuery queryKey, value
						$scope.removeFilter = (e, item) ->
							e.stopPropagation();
							$scope.selected = _.reject $scope.selected, (v) -> v.id == item.id
							_.each $scope.saveAs, (valueKey, queryKey) ->
								value = _.pluck($scope.selected, valueKey) if $scope.selected.length
								ctrl.setQuery queryKey, value
						loadFromQuery = (query, callback) ->
							if !query then return
							updateSelection()
							_.each $scope.saveAs, (valueKey, queryKey) ->
								_.each $scope.data, (item) ->
									if _.contains query[queryKey], item[valueKey]
										$scope.setFilter item
										callback() if _.isFunction callback
						resetToDefault = ->
							if $scope.defaultFilter.length
								_.each $scope.defaultFilter, (item) ->
									$scope.setFilter(item)
							else
								$scope.selected = []
								$scope.setFilter(null)
					else #========================================================================================
						$scope.defaultFilter = null
						updateSelection = (item) ->
							$scope.selected = item
							_.each $scope.saveAs, (valueKey, queryKey) ->
								ctrl.setQuery queryKey, item && item[valueKey]
						loadFromQuery = (query, callback) ->
							if !query then return
							$scope.selected = angular.copy $scope.defaultFilter
							_.each $scope.saveAs, (valueKey, queryKey) ->
								if _.isUndefined query[queryKey]
									$scope.setFilter null
									callback() if _.isFunction callback
									return
								findBy = {}
								findBy[valueKey] = query[queryKey]
								item = _.findWhere $scope.data, findBy
								if item
									$scope.setFilter item
									callback() if _.isFunction callback
						resetToDefault = ->
							$scope.setFilter($scope.defaultFilter)
					#=============================================================================================

				$scope.selected = angular.copy $scope.defaultFilter
				$scope.setFilter = (item) ->
					updateSelection(item)
					$scope.onChange(item) if _.isFunction $scope.onChange

				$scope.isFinite = _.isFinite
				$scope.$watch 'data', (data) ->
					if !_.findWhere data, {id: $scope.selected && $scope.selected.id} then resetFilter()
					if !isItemLoaded then loadFromQuery(ctrl.loadedQuery, -> isItemLoaded = true)
				, true
				$scope.$watch 'default', (defaultFilter) ->
					if defaultFilter
						$scope.defaultFilter = defaultFilter
						resetFilter() if _.isEmpty(ctrl.loadedQuery)

				resetFilter = ->
					resetToDefault()

				$scope.$on 'resetFilter', ->
					resetFilter()
#					$scope.onChange($scope.defaultFilter) if _.isFunction $scope.onChange

				$scope.$on 'loadQuery', (event, query) ->
					isItemLoaded = false
					loadFromQuery(query, -> isItemLoaded = true)

)()