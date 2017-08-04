@app.controller 'ForecastsController',
	['$scope', '$timeout', '$filter', 'Forecast', 'Team', 'Seller', 'Product', 'TimePeriod', 'shadeColor'
	( $scope,   $timeout,   $filter,   Forecast,   Team,   Seller,   Product,   TimePeriod,   shadeColor ) ->

		$scope.teams = []
		$scope.sellers = []
		$scope.products = []
		$scope.timePeriods = []
		$scope.isUnweighted = true

		emptyFilter = $scope.emptyFilter = {id: null, name: 'All'}
		defaultFilter =
			team: emptyFilter
			seller: emptyFilter
			product: emptyFilter
			timePeriod: emptyFilter
		$scope.filter = angular.copy defaultFilter

		$scope.setFilter = (key, val) ->
			$scope.filter[key] = val

		$scope.resetFilter = ->
			$scope.filter = angular.copy defaultFilter

		$scope.$watch 'filter.team', (team) ->
			if team.id then $scope.filter.seller = emptyFilter
			Seller.query({id: team.id || 'all'}).$promise.then (sellers) ->
				$scope.sellers = _.sortBy sellers, 'name'

		Team.all(all_teams: true).then (teams) ->
			$scope.teams = teams
			$scope.teams.unshift emptyFilter

		Product.all().then (products) ->
			$scope.products = products

		TimePeriod.all().then (timePeriods) ->
			$scope.timePeriods = timePeriods.filter (period) ->
				period.visible and (period.period_type is 'quarter' or period.period_type is 'year')

		colors = ['#8CC135', '#3498DB', '#EAECEE']

		query =
#			time_period_id: 146
#			time_period_id: 34
			year: 2017
		Forecast.query(query).$promise.then (forecast) ->
			$scope.forecast = forecast[0]
			drawChart($scope.forecast, '#forecast-chart')


		$scope.toggleUnweighted = (e) ->
			if !$scope.isChartDrawed
				e.preventDefault()
				return
			$scope.isUnweighted = !$scope.isUnweighted
			$scope.updateChart()

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
				barWidth = 50
				uwBarWidth = 25
				barWidth = uwBarWidth if $scope.isUnweighted
				barMargin = 25
				if $scope.isUnweighted
					columnWidth = barWidth * 2 + barSpaceBetween
				else
					columnWidth = barWidth
				width = chartContainer.width() - margin.left - margin.right
				dataWidth = data.teams.length * (columnWidth + barMargin)
				width = dataWidth if dataWidth > width
			)()
			height = 300

			getColor = (probability) ->
				if _.isNumber probability then shadeColor colors[1], 1 - probability / 100 else colors[0]

			dataset = []
			sets = angular.copy data.stages
			sets.reverse()
			sets.unshift {type: 'revenue'}
			sets.unshift {type: 'quota'}
			sets.push {type: 'quotaLine'}
			_.each data.teams, (team, i) ->
				w0 = 0
				uw0 = 0
				_.each sets, (set, j) ->
					switch set.type
						when 'revenue'
							weighted = team.revenue || 0
							unweighted = team.revenue || 0
							color = getColor(set.probability)
						when 'quota'
							weighted = team.quota || 0
							unweighted = team.quota || 0
							color = colors[2]
						when 'quotaLine'
							weighted = 100000
							unweighted = 100000
							color = 'transparent'
						else
							weighted = team.weighted_pipeline_by_stage[set.id] || 0
							unweighted = team.unweighted_pipeline_by_stage[set.id] || 0
							color = getColor(set.probability)
					if !_.isArray dataset[j] then dataset[j] = []
					dataset[j][i] =
						name: if team.quarter then team.name + ' Q' + team.quarter else team.name
						type: set.type
						quota: team.quota
						w: weighted
						uw: unweighted
						w0: w0
						uw0: uw0
						stage: set.probability
						color: color
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
				yMax = maxValue * 1.2

				items = dataset[0].map((d) -> d.name)
				x = d3.scale.ordinal().domain(items).rangeRoundBands([0, width])
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

			groups.selectAll('rect.w-rect').data((d) -> d)
				.enter()
				.append('rect')
				.attr('class', 'w-rect')
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
				.on 'mouseenter', (d, i) ->
					console.log d
				.attr('class', 'uw-rect')
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

#			quotas = _.last dataset
#			quotaLines = svg.append('g')
#			quotaLines.selectAll('line')
#				.data(quotas)
#				.enter()
#				.append('line')
#				.attr('class', 'quota-line')
#				.attr 'x1', (d, i) ->
#					if !d.quota then return 0
#					if $scope.isUnweighted
#						(columnWidth + barMargin) * (i + 1) - columnWidth / 2 - barWidth - barSpaceBetween / 2
#					else
#						(columnWidth + barMargin) * (i + 1) - columnWidth / 2 - barWidth / 2
#				.attr 'y1', (d) ->
#					y(d.quota)
#				.attr 'x2', (d, i) ->
#					if !d.quota then return 0
#					if $scope.isUnweighted
#						(columnWidth + barMargin) * (i + 1) - columnWidth / 2 - barWidth - barSpaceBetween / 2 + barWidth * 2 + barSpaceBetween
#					else
#						(columnWidth + barMargin) * (i + 1) - columnWidth / 2 - barWidth / 2 + barWidth
#				.attr 'y2', (d) ->
#					y(d.quota)

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

#				quotaLines.selectAll('line').transition().duration(duration / 2)
#					.attr 'x1', (d, i) ->
#						if !d.quota then return 0
#						if $scope.isUnweighted
#							(columnWidth + barMargin) * (i + 1) - columnWidth / 2 - barWidth - barSpaceBetween / 2
#						else
#							(columnWidth + barMargin) * (i + 1) - columnWidth / 2 - barWidth / 2
#					.attr 'y1', (d) ->
#						y(d.quota)
#					.attr 'x2', (d, i) ->
#						if !d.quota then return 0
#						if $scope.isUnweighted
#							(columnWidth + barMargin) * (i + 1) - columnWidth / 2 - barWidth - barSpaceBetween / 2 + barWidth * 2 + barSpaceBetween
#						else
#							(columnWidth + barMargin) * (i + 1) - columnWidth / 2 - barWidth / 2 + barWidth
#					.attr 'y2', (d) ->
#						y(d.quota)

				drawLegend()

	]
