@app.controller 'PublisherFillRateChartController', [
	'$scope', '$timeout', '$filter', '$routeParams', 'PublisherDetails', 'shadeColor'
	($scope,   $timeout,   $filter,   $routeParams,   PublisherDetails,   shadeColor) ->

		CHART_ID = '#fill-rate-chart'

		PublisherDetails.fillRateByMonth(id: $routeParams.id).then (data) ->
			drawChart(data, CHART_ID)

		drawChart = (data, chartId) ->
			if !data then return
			data.reverse()
			chartContainer = angular.element(chartId + '-container')
			tooltip = d3.select(chartId + '-tooltip')
			delay = 500
			duration = 1500
			margin =
				top: 20
				left: 60
				right: 30
				bottom: 50
			barWidth = 60
			barMargin = 60
			width = chartContainer.width() - margin.left - margin.right
			dataWidth = (data.length || 1) * (barWidth + barMargin)
			width = dataWidth if dataWidth > width
			height = 350

			dataset = [
				_.map data, (item) ->
					x: moment(item.year_month).format('MMMM')
					y: item.month_available_impressions
					y1: item.month_unfilled_impressions
				_.map data, (item) ->
					x: moment(item.year_month).format('MMMM')
					y: item.month_filled_impressions
			]
			svg = d3.select(chartId)
				.attr('width', width + margin.left + margin.right)
				.attr('height', height + margin.top + margin.bottom)
				.style('height', 'auto')
				.html('')
				.append('g')
				.attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

			maxValue = d3.max data, (item) -> item.month_available_impressions
			yMax = (maxValue || 1) * 1.2

			xLabels = _.map data, (item) ->
				month = moment(item.year_month).format('MMMM')
				percent = Math.round(item.month_filled_impressions / item.month_available_impressions * 100) || 0
				"#{month} #{percent}%"

			x = d3.scale.ordinal().domain(xLabels).rangeRoundBands([0, width])
			y = d3.scale.linear().domain([yMax, 0]).range([0, height])
			xAxis = d3.svg.axis().scale(x).orient('bottom')
				.innerTickSize(0)
				.outerTickSize(0)
			yAxis = d3.svg.axis().scale(y).orient('left')
				.innerTickSize(-width)
				.tickPadding(10)
				.outerTickSize(0)
				.ticks(if yMax > 4 then 4 else yMax)
				.tickFormat (v) -> $filter('formatMoney')(v).slice(1)

			svg.append('g').attr('class', 'x-axis axis').attr('transform', 'translate(0,' + height + ')').call xAxis
				.selectAll('.tick')
					.attr 'transform', (d, i) ->
						'translate(' + ((barWidth + barMargin) * (i + 1) - barWidth / 2) + ', 0)'
				.selectAll('text')
					.attr 'transform', 'translate(0, 10)'

			svg.append('g').attr('class', 'y-axis axis').call yAxis

			svg.selectAll('.x-axis .tick text')
				.each (d) ->
					el = d3.select(this)
					words = d.split(' ')
					el.text ''
					el.append('tspan').text(words[0])
					el.append('tspan').text(words[1]).attr('x', 0).attr('dy', '18')

			groups = svg.selectAll('g.data-group')
				.data(dataset)
				.enter()
				.append('g')
				.attr 'class', 'data-group'

			svg
				.append('g')
				.attr 'class', 'data-group'
				.selectAll('text.total-text')
				.data(dataset[0])
				.enter()
				.append('text')
				.attr 'class', 'total-text'
				.attr 'id', (d, i) -> 'total-text-' + i
				.style {'text-anchor': 'middle', 'font-size': 16}
#				.text (d) -> $filter('formatMoney')(d.y).slice(1)
				.text (d) -> $filter('currency')(d.y, '', 0)
				.attr 'x', (d, i) -> (barWidth + barMargin) * (i + 1) - barWidth / 2
				.attr 'y', (d) -> y(d.y) - 10

			rects = groups.selectAll('rect')
				.data((d) -> d)
				.enter()
				.append('rect')
				.attr 'class', (d, i) -> if !d.y1 then 'imp-rect' else 'total-imp-rect'

			rects
				.attr 'x', (d, i) -> (barWidth + barMargin) * (i + 1) - barWidth / 2 - barWidth / 2
				.attr 'y', (d, i) -> height
				.attr 'width', barWidth
				.attr 'height', 0
				.transition().delay(delay).duration(duration).ease('bounce')
				.attr 'y', (d, i) -> y(d.y)
				.attr 'height', (d, i) -> height - y(d.y)

			rects
				.on 'mouseenter', (d, i) ->
					value = $filter('currency')(d.y1 || d.y, '', 0)
					content = """<span>#{value}</span>"""
					tooltip
						.classed 'active', true
						.html(content)
					d3.select('#total-text-' + i).classed 'active', true
				.on 'mousemove', () ->
					tooltip
						.style('left', (d3.event.clientX + 15) + 'px')
						.style('top', (d3.event.clientY + 20) + 'px');
				.on 'mouseleave', (d, i) ->
					tooltip.classed 'active', false
					d3.select('#total-text-' + i).classed 'active', false

]
