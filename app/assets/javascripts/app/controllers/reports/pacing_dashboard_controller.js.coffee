@app.controller 'PacingDashboardController',
    ['$scope', '$filter'
    ( $scope,   $filter ) ->

        $scope.metrics = [
            'Pipeline'
            'Revenue'
            'Forecast Amt'
        ]
        getRandomValue = (min, max)-> Math.round(Math.random() * (max - min)) + min

        data = [
            {
                name: 'current_quarter'
                values: [1..13].map -> getRandomValue(100000, 500000)
            }
            {
                name: 'previous_quarter'
                values: [1..13].map -> getRandomValue(250000, 350000)
            }
            {
                name: 'current_year'
                values: [1..13].map -> getRandomValue(300000, 560000)
            }
            {
                name: 'previous_year'
                values: [1..13].map -> getRandomValue(200000, 400000)
            }
        ]

        drawChart = (data) ->
#            if !data || !data.length then return
            chartId = '#pipeline-revenue-chart'
            chartContainer = angular.element(chartId + '-container')
            delay = 500
            duration = 2000
            margin =
                top: 10
                left: 45
                right: 10
                bottom: 30
            legendHeight = 50
            width = chartContainer.width() - margin.left - margin.right || 800
            height = 400

            xLabels = [1..13] #WEEKS
            currentWeek = getRandomValue(1, 13)

            svg = d3.select(chartId)
                .attr('width', width + margin.left + margin.right)
                .attr('height', height + margin.top + margin.bottom + legendHeight)
                .html('')
                .append('g')
                .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

            yMax = d3.max data, (item) -> d3.max item.values
            yMax = (yMax || 0) * 1.2

#            yParts = 5
#            yValues = [yParts..0].map (i) -> yMax / yParts * i

            _.forEach data, (d) ->
                if d.goal > xMax then xMax = d.goal

            x = d3.scale.ordinal().domain(xLabels).rangeBands([0, width])
            y = d3.scale.linear().domain([yMax, 0]).range([0, height])

            xAxis = d3.svg.axis().scale(x).orient('bottom')
                .outerTickSize(0)
                .innerTickSize(0)
                .tickPadding(10)
                .tickFormat (v, i) ->
                    if currentWeek == i + 1
                        d3.select(this)
                            .style 'font-weight', 'bold'
                            .style 'font-size', '12px'
                    'Week ' + v
            yAxis = d3.svg.axis().scale(y).orient('left')
                .innerTickSize(-width)
                .tickPadding(10)
                .outerTickSize(0)
                .ticks(6)
                .tickFormat (v) -> $filter('formatMoney')(v)

            svg.append('g').attr('class', 'axis').attr('transform', 'translate(0,' + height + ')').call xAxis
            svg.append('g').attr('class', 'axis').call yAxis
#            svg.selectAll('.tick')
#                .data(data)
#                .enter()
#                .style('font-weight', 'bold')

            console.log currentWeek
            svg.append('line')
                .attr('class', 'week-line')
                .attr 'x1', x(currentWeek) + x(2) / 2
                .attr 'y1', height
                .attr 'x2', x(currentWeek) + x(2) / 2
                .attr 'y2', height
                .transition()
                .duration(duration / 2)
                .ease('linear')
                .attr('y1', 0)

            color = d3.scale.category10()

            graphLine = d3.svg.line()
                .x((value, i) -> x(i + 1) + x(2) / 2)
                .y((value, i) -> y(value))

            graphs = svg.selectAll('.graph')
                .data(data)
                .enter()
                .append('path')
                .attr('class', 'graph')
                .style 'stroke', (d) -> color d.name
                .attr 'd', (d) -> graphLine(d.values)

            totalLength = graphs.node().getTotalLength()
            graphs
                .attr('stroke-dasharray', totalLength + ' ' + totalLength)
                .attr('stroke-dashoffset', totalLength)
                .transition()
                .delay(delay)
                .duration(duration)
                .ease('linear')
                .attr('stroke-dashoffset', 0)

#
        drawChart(data)

    ]