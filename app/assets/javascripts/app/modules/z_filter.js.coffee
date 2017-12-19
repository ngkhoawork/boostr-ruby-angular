(->
	angular.module('zFilterModule', [])

	.controller 'ZFilterController', ['$scope', 'localStorageService', 'ReportQuery', ($scope, LS, ReportQuery) ->
		$scope.ctrl = this
		ctrl = this
		ctrl.reportName = _.last(window.location.pathname.split('/'))
		$scope.recentQueries = LS.get(ctrl.reportName) || []
		$scope.savedQueries = []
		$scope.savedQueriesLoaded = false
		(getSavedQueries = (isInit) ->
			ReportQuery.get(query_type: ctrl.reportName).then (data) ->
				$scope.savedQueries = _.map data, (q) -> q.filter_params = JSON.parse(q.filter_params); q
				defaultQuery = _.findWhere $scope.savedQueries, default: true
				ctrl.loadQuery((isInit && defaultQuery) || $scope.recentQueries[0])
				ctrl.syncQueries()
				$scope.savedQueriesLoaded = true
		)(true)
		$scope.isFilterApplied = false
		$scope.$on 'report_queries_updated', -> getSavedQueries()
		$scope.$on 'zFilterChanged', ->
			$scope.selectedQuery = null
		ctrl.query = {}
		ctrl.syncQueries = ->
			_.each $scope.recentQueries, (recentQuery) ->
				recentQuery.name = recentQuery.original_name
				_.each $scope.savedQueries, (savedQuery) ->
					if _.isEqual(savedQuery.filter_params, recentQuery.filter_params)
						recentQuery.name = savedQuery.name
		ctrl.saveRecentQuery = ->
			if _.isEmpty ctrl.query then return
			$scope.recentQueries = _.filter $scope.recentQueries, (q) =>
				!_.isEqual ctrl.query, q.filter_params
			date = moment().format('MM/DD/YY')
			$scope.recentQueries.unshift(
				name: 'Created ' + date
				original_name: 'Created ' + date
				filter_params: angular.copy ctrl.query
			)
			if $scope.recentQueries.length > 5 then $scope.recentQueries.pop()
			LS.set(ctrl.reportName, $scope.recentQueries)
			ctrl.syncQueries()
		ctrl.saveQuery = (query, callback) ->
#			$scope.savedQueries.unshift item
#			query.filter_params = angular.toJson query.filter_params
			if query.id
				ReportQuery.update(id: query.id, filter_query: query).then ->
					callback() if _.isFunction callback
			else
				ReportQuery.save(filter_query: query).then ->
					callback() if _.isFunction callback
		ctrl.loadQuery = (query) ->
			if !query || _.isEmpty query.filter_params then return
			ctrl.loadedQuery = query.filter_params
			$scope.$broadcast 'loadQuery', query.filter_params
		ctrl.deleteQuery = (query) ->
			ReportQuery.delete(id: query.id)
		ctrl.appliedQuery = null
		ctrl.setQuery = (key, value) ->
			ctrl.query[key] = value
			if !value then delete ctrl.query[key]
			ctrl.checkApplied()
		ctrl.checkApplied = ->
			$scope.isFilterApplied = _.isEqual ctrl.query, ctrl.appliedQuery

		$scope.$watch('ctrl.query', (query) =>
			$scope.currentSelection = query
		, true)

		ctrl
	]

	.directive 'zFilter', ['$timeout', ($timeout) ->
		restrict: 'E'
		replace: true
		transclude: true
		scope:
			onApply: '='
			currentSelection: '='
		controller: 'ZFilterController'
		templateUrl: 'modules/z_filter.html'
		link: ($scope, el, attrs, ctrl, trans) ->
			trans (clone) -> el.find('.element-to-replace').replaceWith(clone)
			$scope.isQueryDropdownOpen = false
			$scope.isQueryFormOnEdit = false
			$scope.selectedQuery = null
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
				$scope.onApply(angular.copy(ctrl.query))
				ctrl.appliedQuery = angular.copy ctrl.query
				ctrl.saveRecentQuery()
				ctrl.checkApplied()
			$scope.saveQuery = (e, query) ->
				e.stopPropagation()
				$scope.isQueryFormOnEdit = true
				$scope.savedQueryForm.filter_params = angular.toJson query.filter_params
				$timeout -> angular.element('.query-name-input').focus()
			$scope.submitQueryForm = ->
				ctrl.saveQuery $scope.savedQueryForm, ->
					resetQueryForm()
			$scope.editQuery = (e, query) ->
				e.stopPropagation()
				$scope.isQueryFormOnEdit = true
				$timeout -> angular.element('.query-name-input').focus()
				$scope.savedQueryForm = angular.copy query
			$scope.deleteQuery = (e, query) ->
				e.stopPropagation()
				ctrl.deleteQuery(query)
			$scope.cancelQueryForm = ->
				resetQueryForm()
			$scope.loadQuery = (query) ->
				$scope.selectedQuery = null
				ctrl.loadQuery(query)
			$scope.switchDefault = (e, query) ->
				e.stopPropagation()
				query = angular.copy query
				query.default = !query.default
				ctrl.saveQuery query
			$scope.resetFilter = ->
				ctrl.query = {}
				ctrl.loadedQuery = {}
				ctrl.checkApplied()
				$scope.$broadcast 'resetFilter'
			$scope.compareQueries = (query) ->
				if _.isEqual query.filter_params, ctrl.query
					$scope.selectedQuery = query
					true
				else
					false
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
			orderBy: '='
		templateUrl: 'modules/z_filter_field.html'
		compile: (el, attrs) ->
			attrs.type = attrs.type || 'list' #default type
			post: ($scope, el, attrs, ctrl, trans) ->
				trans (clone) -> el.find('.element-to-replace').replaceWith(clone)
				$scope.isAll = !(attrs.isAll == 'false')
				isItemLoaded = false

				switch $scope.type
					when 'daterange' #==================================================================================
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
						$scope.removeFilter = (e) ->
							e.stopPropagation()
							$scope.setFilter(angular.copy $scope.defaultFilter.date)
					when 'stage', 'multiselect' #=======================================================================
						$scope.defaultFilter = []
						$scope.isStageSelected = (id) ->
							_.findWhere $scope.selected, id: id
						updateSelection = (item) ->
							if item
								$scope.selected.push item if !_.contains $scope.selected, item
							else
								$scope.selected = []
							_.each $scope.saveAs, (valueKey, queryKey) ->
								if $scope.selected.length
									value = _.pluck($scope.selected, valueKey)
									value = _.sortBy value
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
					else #==============================================================================================
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
						$scope.removeFilter = (e) ->
							e.stopPropagation()
							$scope.setFilter(null)
					#===================================================================================================

				$scope.selected = angular.copy $scope.defaultFilter
				$scope.setFilter = (item) ->
					$scope.$emit 'zFilterChanged'
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