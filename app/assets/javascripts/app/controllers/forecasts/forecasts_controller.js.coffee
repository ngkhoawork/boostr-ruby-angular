@app.controller 'ForecastsController',
	['$scope', '$filter', 'Forecast', 'Team', 'Seller', 'Product', 'shadeColor'
	( $scope,   $filter,   Forecast,   Team,   Seller,   Product,   shadeColor ) ->

		$scope.teams = []
		$scope.sellers = []
		$scope.products = []

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

		colors = ['#8CC135', '#3498DB']
#		getColor = (i) -> if i is 0 then colors[0] else shadeColor colors[1], 0.15 * (i - 1)

		query =
#			time_period_id: 146
			year: 2017
		Forecast.query(query).$promise.then (forecast) ->
			drawChart(forecast[0], '#forecast-chart')

		$scope.updateChart = null

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
			barWidth = 30
			barMargin = 40
			width = chartContainer.width() - margin.left - margin.right
			dataWidth = data.teams.length * (barWidth + barMargin)
			width = dataWidth if dataWidth > width
			height = 300

			getColor = (probability) ->
				if _.isNumber probability then shadeColor colors[1], 1 - probability / 100 else colors[0]

			$scope.dataset = dataset = []
			stages = angular.copy data.stages
			stages.reverse()
			stages.unshift {}
			_.each data.teams, (team, i) ->
				_.each stages, (stage, j) ->
					number = if j is 0 then team.revenue else team.weighted_pipeline_by_stage[stage.id]
					if !_.isArray dataset[j] then dataset[j] = []
#					if !_.isFinite number then return
					dataset[j][i] =
						x: if team.quarter then team.name + ' Q' + team.quarter else team.name
						y: number || 0
						stage: stage.probability
						color: getColor(stage.probability)
#					for item, k in data.teams
#						if j != 0 && !_.isFinite item.weighted_pipeline_by_stage[stage.id]
#							dataset[j][k] =
#								x: if item.quarter then item.name + ' Q' + item.quarter else item.name
#								y: 0
#								color: getColor(stage.probability)

			stack = d3.layout.stack()
			stack dataset

			dataset = dataset.map (group) ->
				group.map (d) ->
					x: d.x
					y: d.y
					y0: d.y0
					stage: d.stage
					color: d.color


			svg = d3.select(chartId)
				.attr('width', width + margin.left + margin.right)
				.attr('height', height + margin.top + margin.bottom)
				.html('')
				.append('g')
				.attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
			maxValue = d3.max(dataset, (group) ->
				d3.max group, (d) ->
					d.y + d.y0
			)
			yMax = maxValue * 1.2
#			_.forEach data, (d) ->
#				if d.goal > yMax then yMax = d.goal

			items = dataset[0].map((d) -> d.x)
			x = d3.scale.ordinal().domain(items).rangeRoundBands([0, width])
			y = d3.scale.linear().domain([yMax, 0]).range([0, height])
			xAxis = d3.svg.axis().scale(x).orient('bottom')
			yAxis = d3.svg.axis().scale(y).orient('left')
				.innerTickSize(-width)
				.tickPadding(10)
				.outerTickSize(0)
				.ticks(if yMax > 6 then 6 else yMax || 1)
				.tickFormat (v) -> $filter('formatMoney')(v)

			svg.append('g').attr('class', 'axis').attr('transform', 'translate(0,' + height + ')').call xAxis
				.selectAll('.tick')
					.attr 'transform', (d, i) ->
						'translate(' + ((barMargin + barWidth) * (i + 1)) + ',0)'
				.selectAll('text')
					.attr 'transform', (d, i) ->
						'rotate(-20) translate(20, 5)'
					.style 'text-anchor', 'end'
			svg.append('g').attr('class', 'axis').call yAxis

			groups = svg.selectAll('g.data-group')
				.data(dataset)
				.enter()
				.append('g')
				.attr('class', 'data-group')
				.style 'fill', (d, i) ->
					d[0].color

			groups.selectAll('rect').data((d) -> d)
				.enter()
				.append('rect')
				.attr('class', 'data-rect')
				.attr 'x', (d, i) ->
					(barMargin + barWidth) * (i + 1) - barWidth / 2
				.attr 'y', height
				.attr 'width', barWidth
				.attr 'height', 0
				.transition().delay(delay).duration(duration).ease('bounce')
				.attr 'y', (d) ->
					y(d.y0) + y(d.y) - height
				.attr 'height', (d) ->
					height - y(d.y)

#			goalLines = svg.append('g')
#			goalLines.selectAll('line')
#				.data(data)
#				.enter()
#				.append('line')
#				.attr('class', 'goal-line')
#				.attr 'y1', (d) ->
#					(y d.name) + y.rangeBand() / 2 - barWidth / 1.3
#				.attr 'y2', (d) ->
#					(y d.name) + y.rangeBand() / 2 - barWidth / 1.3
#				.attr 'x1', (d) ->
#					x d.goal
#				.attr 'x2', (d) ->
#					x d.goal
#				.transition().delay(delay * 2).duration(duration / 2)
#				.attr 'y2', (d) ->
#					(y d.name) + y.rangeBand() / 2 + barWidth / 1.3

#			#legend
			legendData = [
				{color: 'gray', label: 'Goal'}
				{color: colors[0], label: 'Revenue'}
			]
			stages.shift()
#			stages.reverse()
			legendStages = _.map dataset, (group) ->
				arr = _.map group, (item) -> item.y && item.stage
				_.compact arr

			legendStages = _.union.apply(this, legendStages)
			console.log legendStages
			_.forEach legendStages, (stage) ->
#				if i is 0
#					legendData.push	{color: colors[0], label: 'Revenue'}
#				else
					legendData.push {color: getColor(stage), label: stage + '%'}

#			legend = svg.append("g")
#				.attr("transform", "translate(0, " + (height + 50) + ")")
#				.attr("class", "legendTable")
#
#			goalLegend = legend
#				.append('g')
#				.attr('class', 'legend')
#			goalLegend
#				.append('line')
#				.attr('class', 'goal-line')
#				.attr 'x1', 0
#				.attr('y1', 5)
#				.attr("x2", 26)
#				.attr("y2", 5)
#			goalLegend
#				.append('text')
#				.attr 'x', 34
#				.attr('y', 10)
#				.attr('height', 30)
#				.attr('width', 150)
#				.text legendData[0].label
#
#			legendWithData = legend
#				.selectAll('.legend')
#				.data(legendData)
#				.enter()
#				.append('g')
#				.attr('class', 'legend')
#				.attr('transform', (d, i) -> 'translate(' + (i % 6) * 100 + ', 0)')
#			legendWithData.append('rect')
#				.attr 'x', 0
#				.attr('y', (d, i) -> Math.floor(i / 6) * 20)
#				.attr('width', 13)
#				.attr('height', 13)
#				.attr("rx", 4)
#				.attr("ry", 4)
#				.style 'fill', (d) -> d.color
#			legendWithData.append('text')
#				.attr 'x', 20
#				.attr('y', (d, i) -> Math.floor(i / 6) * 20 + 10)
#				.attr('height', 30)
#				.attr('width', 150)
#				.text (d) -> d.label
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
			#            legend.append('div')
			#                .attr('class', 'legend-icon')
			#                .style 'background-color', (d) -> d.color
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
			legend.append('span')
				.attr 'class', 'legend-text'
				.html (d) -> d.label

	]
