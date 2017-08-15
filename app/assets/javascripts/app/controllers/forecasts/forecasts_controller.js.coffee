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
			searchAndSetSeller($scope.filter.team, $scope.currentUser)

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

				params = { time_period_id: $scope.filter.timePeriod.id, quarter: row.quarter  }
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
			searchAndSetSeller(team, $scope.currentUser)
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

		searchAndSetSeller = (team, user) ->
			if !team.id then return
			if team.leader_id is user.id or _.findWhere team.members, {id: user.id}
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
					drawChart($scope.forecast, '#forecast-chart')
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
					drawChart($scope.forecast, '#forecast-chart')

		$scope.toggleUnweighted = (e) ->
			if !$scope.isChartDrawed
				e.preventDefault()
				return
			$scope.isUnweighted = !$scope.isUnweighted
			$scope.updateChart()

		colors = ['#8CC135', '#3498DB', '#EAECEE']
		drawChart = (data, chartId) ->
			if !data then return
			chartContainer = angular.element(chartId + '-container')
			tooltip = d3.select(chartId + '-tooltip')
			delay = 500
			duration = 1500
			margin =
				top: 0
				left: 60
				right: 30
				bottom: 70
			barSpaceBetween = 6
			barWidth = null
			uwBarWidth = null
			barMargin = null
			columnWidth = null
			width = null
			dataWidth = null
			(updateBarSizes = ->
				barWidth = 56
				uwBarWidth = 25
				barWidth = uwBarWidth if $scope.isUnweighted
				if $scope.isUnweighted
					barMargin = 30
					columnWidth = barWidth * 2 + barSpaceBetween
				else
					barMargin = 25
					columnWidth = barWidth
				width = chartContainer.width() - margin.left - margin.right
				dataWidth = (data.teams && data.teams.length || 1) * (columnWidth + barMargin)
				width = dataWidth if dataWidth > width
			)()
			height = 300

			getColor = (probability) ->
				if _.isFinite probability then shadeColor colors[1], 0.95 - 0.95 * probability / 100 else colors[0]

			dataset = []
			sets = angular.copy(data.stages)
			if !sets
				sets = _.pluck(data, 'stages')
				sets = _.union.apply(this, sets)
				sets = _.uniq(sets, 'id')
			sets.reverse()
			sets.unshift {type: 'revenue'}
			sets.unshift {type: 'quota'}
			sets.push {type: 'quotaLine'}
			items = switch data.type
				when 'team'
					[].concat data.teams, data.members, data.leader
				when 'member'
					[data]
				else
					if data.length > 1 then data else data.teams
			_.each items, (item, i) ->
				if !item then return
				w0 = 0
				uw0 = 0
				tt = {w: {}, uw: {}}
				_.each sets, (set, j) ->
					switch set.type
						when 'revenue'
							weighted = item.revenue || 0
							unweighted = item.revenue || 0
							tt.revenue = item.revenue
							color = getColor(set.probability)
						when 'quota'
							weighted = item.quota || 0
							unweighted = item.quota || 0
							color = colors[2]
						when 'quotaLine'
							weighted = 0
							unweighted = 0
							color = 'transparent'
						else
							weighted = Number(item.weighted_pipeline_by_stage[set.id]) || 0
							unweighted = Number(item.unweighted_pipeline_by_stage[set.id]) || 0
							color = getColor(set.probability)
					if !_.isArray dataset[j] then dataset[j] = []
					if _.isNumber(set.probability)
						tt.w[set.probability] = weighted
						tt.uw[set.probability] = unweighted
					dataset[j][i] =
						name: if item.quarter then item.name + ' Q' + item.quarter else item.name
						type: set.type
						quota: item.quota || 0
						w: weighted
						uw: unweighted
						w0: w0
						uw0: uw0
						stage: set.probability
						color: color
						tooltip: tt
					if set.type != 'quota'
						w0 += weighted
						uw0 += unweighted

			svg = d3.select(chartId)
				.attr('width', width + margin.left + margin.right)
				.attr('height', height + margin.top + margin.bottom)
				.html('')
				.append('g')
				.attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

			x = null
			y = null
			xAxis = null
			yAxis = null
			(initAxis = ->
				maxValue = d3.max(dataset, (group) ->
					if $scope.isUnweighted
						wMax = d3.max group, (d) -> d.w + d.w0
						uwMax = d3.max group, (d) -> d.uw + d.uw0
						Math.max wMax, uwMax
					else
						d3.max group, (d) -> d.w + d.w0
				)
				yMax = (maxValue || 1) * 1.2

				xLabels = _.pluck(dataset[0], 'name')
				x = d3.scale.ordinal().domain(xLabels).rangeRoundBands([0, width])
				y = d3.scale.linear().domain([yMax, 0]).range([0, height])
				xAxis = d3.svg.axis().scale(x).orient('bottom')
				yAxis = d3.svg.axis().scale(y).orient('left')
					.innerTickSize(-width)
					.tickPadding(10)
					.outerTickSize(0)
					.ticks(if yMax > 6 then 6 else yMax || 1)
					.tickFormat (v) -> $filter('formatMoney')(v)
			)()

			svg.append('g').attr('class', 'x-axis axis').attr('transform', 'translate(0,' + height + ')').call xAxis
				.selectAll('.tick')
					.attr 'transform', (d, i) ->
						'translate(' + ((columnWidth + barMargin) * (i + 1) - columnWidth / 2) + ', 0)'
				.selectAll('text')
					.attr 'transform', 'rotate(-20) translate(20, 5)'
					.style 'text-anchor', 'end'
			svg.append('g').attr('class', 'y-axis axis').call yAxis

			groups = svg.selectAll('g.data-group')
				.data(dataset)
				.enter()
				.append('g')
				.attr('class', 'data-group')
				.style 'fill', (d, i) ->
					d[0].color

			curr = (v) -> $filter('currency')(v, '$', 0)

			groups.selectAll('rect.w-rect').data((d) -> d)
				.enter()
				.append('rect')
				.attr('class', 'w-rect')
				.on 'mouseenter', (d, i) ->
					content = "<div><b>#{d.name}</b></div>"
					_.map d.tooltip.w, (val, key) ->
						if !val then return
						content += """<div>
										<span class="tip-icon" style="background-color: #{getColor(key)}"></span>
										#{key}% <span class="tip-text">#{curr(val)}</span>
									  </div>"""
					content += """<div>
									<span class="tip-icon" style="background-color: #{getColor()}"></span>
									Revenue <span class="tip-text">#{curr(d.tooltip.revenue)}</span>
								  </div>"""
					tooltip
						.classed 'active', true
						.html(content)
				.on 'mousemove', () ->
					tooltip
						.style('left', (d3.event.clientX + 6) + 'px')
						.style('top', (d3.event.clientY - tooltip.node().clientHeight - 6) + 'px');
				.on 'mouseleave', () ->
					tooltip.classed 'active', false
				.attr 'x', (d, i) ->
					if $scope.isUnweighted
						(columnWidth + barMargin) * (i + 1) - columnWidth / 2 - barWidth - barSpaceBetween / 2
					else
						(columnWidth + barMargin) * (i + 1) - columnWidth / 2 - barWidth / 2
				.attr 'y', height
				.attr 'width', barWidth
				.attr 'height', 0
				.transition().delay(delay).duration(duration).ease('bounce')
				.attr 'y', (d) ->
					y(d.w0) + y(d.w) - height
				.attr 'height', (d) ->
					height - y(d.w)


			groups.selectAll('rect.uw-rect').data((d) -> d)
				.enter()
				.append('rect')
				.attr('class', 'uw-rect')
				.on 'mouseenter', (d, i) ->
					content = "<div><b>#{d.name}</b></div>"
					_.map d.tooltip.uw, (val, key) ->
						if !val then return
						content += """<div>
										<span class="tip-icon" style="background-color: #{getColor(key)}"></span>
										#{key}% <span class="tip-text">#{curr(val)}</span>
									  </div>"""
					content += """<div>
									<span class="tip-icon" style="background-color: #{getColor()}"></span>
									Revenue <span class="tip-text">#{curr(d.tooltip.revenue)}</span>
								  </div>"""
					tooltip
						.classed 'active', true
						.html(content)
				.on 'mousemove', () ->
					tooltip
						.style('left', (d3.event.clientX + 6) + 'px')
						.style('top', (d3.event.clientY - tooltip.node().clientHeight - 6) + 'px');
				.on 'mouseleave', () ->
					tooltip.classed 'active', false
				.attr 'x', (d, i) ->
					if $scope.isUnweighted
						(columnWidth + barMargin) * (i + 1) - columnWidth / 2 + barSpaceBetween / 2
					else
						(columnWidth + barMargin) * (i + 1) - columnWidth / 2 + barWidth / 2
				.attr 'y', height
				.attr 'width', uwBarWidth
				.attr 'height', 0
				.transition().delay(delay).duration(duration).ease('bounce')
				.attr 'y', (d) ->
					if $scope.isUnweighted
						y(d.uw0) + y(d.uw) - height
					else
						height
				.attr 'height', (d) ->
					if $scope.isUnweighted
						height - y(d.uw)
					else
						0

			quotas = _.last dataset
			quotaLines = svg.append('g')
			quotaLines.selectAll('line')
				.data(quotas)
				.enter()
				.append('line')
				.attr('class', 'quota-line')
				.attr 'x1', (d, i) ->
					if !d.quota then return 0
					if $scope.isUnweighted
						(columnWidth + barMargin) * (i + 1) - columnWidth / 2 - barWidth - barSpaceBetween / 2
					else
						(columnWidth + barMargin) * (i + 1) - columnWidth / 2 - barWidth / 2
				.attr 'y1', (d) ->
					y(d.quota)
				.attr 'x2', (d, i) ->
					if !d.quota then return 0
					if $scope.isUnweighted
						(columnWidth + barMargin) * (i + 1) - columnWidth / 2 - barWidth - barSpaceBetween / 2 + barWidth * 2 + barSpaceBetween
					else
						(columnWidth + barMargin) * (i + 1) - columnWidth / 2 - barWidth / 2 + barWidth
				.attr 'y2', (d) ->
					y(d.quota)

#			#legend
			(drawLegend = ->
				legendData = [
					{color: 'gray', label: 'Quota'}
					{color: colors[0], label: 'Revenue'}
				]
				legendStages = _.map dataset, (group) ->
					if $scope.isUnweighted
						arr = _.map group, (item) -> if item.uw || item.w then item.stage
					else
						arr = _.map group, (item) -> if item.w then item.stage
					sets = _.filter arr, (stage) -> _.isNumber stage
				legendStages = _.union.apply(this, legendStages)
				legendStages.sort (s1, s2) -> s2 - s1

				_.forEach legendStages, (stage) ->
					legendData.push {color: getColor(stage), label: stage + '%'}

				legendContainer = d3.select(chartId + '-container .legend-container')
					.html('')
					.style 'margin-left', margin.left + 'px'
				goalLegend = legendContainer
					.append('div')
					.attr('class', 'legend')
				goalLegend.append('svg')
					.style 'width', '28'
					.style 'height', '13'
					.style 'margin-right', '8px'
					.append('line')
					.attr 'stroke-dasharray', '6, 4'
					.style 'stroke', legendData[0].color
					.style 'stroke-width', 2
					.attr 'x1', 0
					.attr 'y1', 6
					.attr 'x2', 28
					.attr 'y2', 6
				goalLegend.append('span')
					.attr 'class', 'legend-text'
					.html legendData[0].label

				legend = legendContainer
					.selectAll('.legend')
					.data(legendData)
					.enter()
					.append('div')
					.attr('class', 'legend')
				legend.append('svg')
					.style 'width', '13'
					.style 'height', '13'
					.style 'margin-right', '4px'
					.append('rect')
					.attr 'x', 0
					.attr 'y', 0
					.attr('width', 13)
					.attr('height', 13)
					.attr("rx", 4)
					.attr("ry", 4)
					.style 'fill', (d) -> d.color
					.style 'stroke', (d) -> '#e4e4e4'
				legend.append('span')
					.attr 'class', 'legend-text'
					.html (d) -> d.label
			)()

			$timeout (-> $scope.isChartDrawed = true), duration

			$scope.updateChart = ->

				updateBarSizes()
				initAxis()

				d3.select(chartId)
					.transition().duration(duration / 2)
					.attr('width', width + margin.left + margin.right)

				svg.select('.y-axis')
					.transition().duration(duration / 2)
					.call yAxis
				svg.select('.x-axis')
					.transition().duration(duration / 2)
					.call xAxis
					.selectAll('.tick')
						.attr 'transform', (d, i) ->
							'translate(' + ((columnWidth + barMargin) * (i + 1) - columnWidth / 2) + ', 0)'
					.selectAll('text')
						.attr 'transform', 'rotate(-20) translate(20, 5)'
						.style 'text-anchor', 'end'

				if $scope.isUnweighted
					uwDelay = duration / 2
					wDelay = 0
				else
					uwDelay = 0
					wDelay = duration / 2

				groups.selectAll('rect.uw-rect').transition().duration(duration / 2)
					.attr 'x', (d, i) ->
						if $scope.isUnweighted
							(columnWidth + barMargin) * (i + 1) - columnWidth / 2 + barSpaceBetween / 2
						else
							(columnWidth + barMargin) * (i + 1) - columnWidth / 2 + barWidth / 2
					.attr 'width', ->
						uwBarWidth
					.attr 'y', (d) ->
						if $scope.isUnweighted
							y(d.uw0) + y(d.uw) - height
						else
							height
					.attr 'height', (d) ->
						if $scope.isUnweighted
							height - y(d.uw)
						else
							0

				groups.selectAll('rect.w-rect').transition().duration(duration / 2)
					.attr 'width', barWidth
					.attr 'x', (d, i) ->
						if $scope.isUnweighted
							(columnWidth + barMargin) * (i + 1) - columnWidth / 2 - barWidth - barSpaceBetween / 2
						else
							(columnWidth + barMargin) * (i + 1) - columnWidth / 2 - barWidth / 2

				quotaLines.selectAll('line').transition().duration(duration / 2)
					.attr 'x1', (d, i) ->
						if !d.quota then return 0
						if $scope.isUnweighted
							(columnWidth + barMargin) * (i + 1) - columnWidth / 2 - barWidth - barSpaceBetween / 2
						else
							(columnWidth + barMargin) * (i + 1) - columnWidth / 2 - barWidth / 2
					.attr 'y1', (d) ->
						y(d.quota)
					.attr 'x2', (d, i) ->
						if !d.quota then return 0
						if $scope.isUnweighted
							(columnWidth + barMargin) * (i + 1) - columnWidth / 2 - barWidth - barSpaceBetween / 2 + barWidth * 2 + barSpaceBetween
						else
							(columnWidth + barMargin) * (i + 1) - columnWidth / 2 - barWidth / 2 + barWidth
					.attr 'y2', (d) ->
						y(d.quota)

				drawLegend()

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
