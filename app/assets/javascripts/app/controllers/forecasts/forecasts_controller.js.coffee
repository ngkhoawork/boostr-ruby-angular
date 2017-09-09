@app.controller 'ForecastsController',
	['$scope', '$timeout', '$filter', '$q', 'Forecast', 'WeightedPipeline', 'Revenue', 'Team', 'Seller', 'Product', 'TimePeriod', 'CurrentUser', 'shadeColor'
	( $scope,   $timeout,   $filter,   $q,   Forecast,   WeightedPipeline,   Revenue,   Team,   Seller,   Product,   TimePeriod,   CurrentUser,   shadeColor ) ->

		$scope.filterTeams = []
		$scope.teams = []
		$scope.sellers = []
		$scope.products = []
		$scope.timePeriods = []
		$scope.isUnweighted = false
		$scope.years = [2016..moment().year()]
		$scope.totals = {}

		emptyFilter = $scope.emptyFilter = {id: null, name: 'All'}
		defaultFilter =
			team: emptyFilter
			seller: emptyFilter
			product: emptyFilter
			timePeriod: emptyFilter
			year: null
		$scope.filter = angular.copy defaultFilter
		appliedFilter = null

		$scope.setFilter = (key, val) ->
			switch key
				when 'timePeriod'
					$scope.filter.year = defaultFilter.year
				when 'year'
					$scope.filter.timePeriod = defaultFilter.timePeriod
			$scope.filter[key] = val

		$scope.applyFilter = ->
			appliedFilter = angular.copy $scope.filter
			getData getQuery()

		$scope.isFilterApplied = ->
			!angular.equals $scope.filter, appliedFilter

		$scope.resetFilter = ->
			$scope.filter = angular.copy defaultFilter
			searchAndSetTimePeriod($scope.timePeriods)
			searchAndSetTeam($scope.filterTeams, $scope.currentUser)
			searchAndSetSeller($scope.filter.team.members || $scope.sellers, $scope.currentUser)

		$scope.showSubtable = (row, type, event) ->
			$scope.openedSubtable = row
			link = angular.element(event.target)
			arrow = link.parent().find('.subtable-arrow')
			wrap = link.closest('tr').next().find(".#{type}-subtable")
			container = wrap.find('.subtable-container')

			if wrap.hasClass 'opened'
				arrow.hide()
				wrap.removeClass('opened').height(0)
			else
				link.addClass('loading-subtable')
				angular.element('.subtable-arrow').hide()
				angular.element('.subtable-wrap').removeClass('opened').height(0)

				params = { time_period_id: $scope.filter.timePeriod.id, quarter: row.quarter, product_id: $scope.filter.product.id  }
				if row.type == 'member'
					params = _.extend(params, { member_id: row.id })
				else if row.type == 'team'
					params = _.extend(params, { team_id: row.id })

				onSubtableLoad = ->
					height = container.outerHeight()
					link.removeClass('loading-subtable')
					arrow.show()
					wrap.addClass('opened').height(height)

				switch type
					when 'pipeline'
						WeightedPipeline.get(params).then (weighted_pipeline) ->
							$scope.revenues = null
							$scope.weighted_pipeline = weighted_pipeline
							$scope.sort.weighted_pipeline = new McSort(
								column: "name",
								compareFn: (column, a, b) ->
									switch (column)
										when "name", "client_name", "agency_name", "start_date", "end_date"
											a[column].localeCompare(b[column])
										else
											a[column] - b[column]
								dataset: $scope.weighted_pipeline
							)
							$timeout onSubtableLoad
						, ->
							link.removeClass('loading-subtable')
					when 'revenue'
						Revenue.query(params).$promise.then (revenues) ->
							$scope.weighted_pipeline = null
							$scope.revenues = revenues
							$scope.sort.revenues = new McSort(
								column: "name",
								compareFn: (column, a, b) ->
									switch (column)
										when "name", "agency", "advertiser"
											a[column] && a[column].localeCompare(b[column])
										else
											a[column] - b[column]
								dataset: $scope.revenues
							)
							$timeout onSubtableLoad
						, ->
							link.removeClass('loading-subtable')
			return

		$scope.hideSubtable = ->
			angular.element('.subtable-arrow').hide()
			angular.element('.subtable-wrap').removeClass('opened').height(0)
			return


		$scope.$watch 'filter.team', (team, prevTeam) ->
			if team == prevTeam then return
			if team.id then $scope.setFilter('seller', emptyFilter)
			$scope.setFilter('team', team)
			searchAndSetSeller(team.members, $scope.currentUser)
			Seller.query({id: team.id || 'all'}).$promise.then (sellers) ->
				$scope.sellers = sellers

		$q.all(
			user: CurrentUser.get().$promise
			teams: Team.all(all_teams: true)
			sellers: Seller.query({id: 'all'}).$promise
			products: Product.all()
			timePeriods: TimePeriod.all()
		).then (data) ->
			$scope.filterTeams = data.teams
			$scope.filterTeams.unshift emptyFilter
			searchAndSetTeam(data.teams, data.user) if $scope.currentUserIsLeader
			searchAndSetSeller(data.sellers, data.user)
			$scope.sellers = data.sellers
			$scope.products = data.products
			$scope.timePeriods = data.timePeriods.filter (period) ->
				period.visible and (period.period_type is 'quarter' or period.period_type is 'year')
			searchAndSetTimePeriod($scope.timePeriods)

		searchAndSetTimePeriod = (timePeriods) ->
			for period in timePeriods
				if period.period_type is 'quarter' and
				moment().isBetween(period.start_date, period.end_date, 'days', '[]')
					return $scope.setFilter('timePeriod', period)
			for period in timePeriods
				if period.period_type is 'year' and
				moment().isBetween(period.start_date, period.end_date, 'days', '[]')
					return $scope.setFilter('timePeriod', period)

		searchAndSetTeam = (teams, user) ->
			for team in teams
				if team.leader_id is user.id
					return $scope.setFilter('team', team)
				if team.children && team.children.length
					searchAndSetTeam team.children, user

		searchAndSetSeller = (members, user) ->
			if !_.isArray members then return
			if _.findWhere members, {id: user.id}
				return $scope.setFilter('seller', user)

		getQuery = ->
			f = $scope.filter
			query = {}
			query.team_id = f.team.id || 'all'
			query.user_id = f.seller.id || 'all'
			query.product_id = f.product.id || 'all'
			query.time_period_id = f.timePeriod.id if f.timePeriod.id
			query.year = f.year if f.year
			query.new_version = true
			query

		getData = (query) ->
			if query.id
				Forecast.get(query).$promise.then (forecast) ->
					$scope.forecast = forecast
					$scope.team = forecast
					$scope.teams = forecast.teams
					$scope.members = forecast.members
					$scope.dataset = [$scope.teams || [], $scope.members || []]
					$scope.setMcSort()
					$timeout -> $scope.$broadcast 'drawForecastChart', $scope.forecast
					calcTotals()
			else
				Forecast.query(query).$promise.then (forecast) ->
					if forecast.length > 1 # forecast is a quarterly member array
						$scope.forecast = forecast
						$scope.members = forecast
					else # forecast is either a single top-level company or single member object
						$scope.forecast = forecast[0]
						$scope.teams = forecast[0].teams
						$scope.members = forecast[0].members
						if forecast[0].type && forecast[0].type == "member"
							$scope.member = forecast[0]
					$scope.dataset = [$scope.teams || [], $scope.members || []]
					$scope.setMcSort()
					$timeout -> $scope.$broadcast 'drawForecastChart', $scope.forecast
					calcTotals()

		$scope.isFinite = _.isFinite

		calcTotals = ->
			if $scope.teams || $scope.members
				arr = [].concat $scope.teams, $scope.members
			else
				arr = [$scope.forecast]
			totals =
				name: 'TOTAL'
				type: 'totals'
				quota: 0
				revenue: 0
				weighted_pipeline: 0
				amount: 0
				gap_to_quota: 0
				percent_booked: 0
				percent_to_quota: 0
				new_deals_needed: 0
				wow_weighted_pipeline: 0
				wow_revenue: 0
			_.each arr, (row) ->
				if !row then return
				totals.quota += if row.is_leader then 0 else Number(row.quota) || 0
				totals.revenue += Number(row.revenue) || 0
				totals.weighted_pipeline += Number(row.weighted_pipeline) || 0
				totals.amount += Number(row.amount) || 0
				totals.gap_to_quota += if row.is_leader then 0 else Number(row.gap_to_quota) || 0
				totals.new_deals_needed += if row.is_leader then 0 else Number(row.new_deals_needed) || 0
				totals.wow_weighted_pipeline += Number(row.wow_weighted_pipeline) || 0
				totals.wow_revenue += Number(row.wow_revenue) || 0
			totals.percent_booked = Math.round(totals.revenue / totals.quota * 100)
			totals.percent_to_quota = Math.round(totals.amount / totals.quota * 100)
			$scope.totals = totals

		$scope.$on 'forecastChartDrawn', ->
			$scope.isChartDrawn = true

		$scope.toggleUnweighted = (e) ->
			if !$scope.isChartDrawn
				e.preventDefault()
				return
			$scope.isUnweighted = !$scope.isUnweighted
			$scope.$broadcast 'updateForecastChart'

		class McSort
			constructor: (opts) ->
				@column = opts.column
				@compareFn = opts.compareFn || (-> 0)
				@dataset = opts.dataset || []
				@defaults = opts
				@direction = opts.direction || "asc"
				@hasMultipleDatasets = opts.hasMultipleDatasets || false
				@execute()

			execute: ->
				mcSort = @
				if not @hasMultipleDatasets
					@dataset.sort (a, b) ->
						mcSort.compareFn(mcSort.column, a, b)
					@dataset.reverse() if @direction == "desc"
				else
					@dataset = @dataset.map (row) ->
						row.sort (a, b) ->
							mcSort.compareFn(mcSort.column, a, b)
						row.reverse() if mcSort.direction == "desc"
						row
				@dataset

			reset: ->
				@column = @defaults.column
				@direction = @defaults.direction || "asc"
				@execute()

			toggle: (column) ->
				direction = "asc"
				direction = "desc" if @column == column and @direction == "asc"
				@column = column
				@direction = direction
				@execute()


		$scope.setMcSort = ->
			$scope.sort = new McSort({
				column: "name",
				compareFn: (column, a, b) ->
					switch (column)
						when "name", "agency", "advertiser"
							a[column].localeCompare(b[column])
						else
							a[column] - b[column]
				dataset: $scope.dataset
				hasMultipleDatasets: true
			})

	]
