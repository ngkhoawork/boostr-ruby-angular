@app.controller 'PacingDashboardController',
    ['$scope', '$filter', 'PacingDashboard'
    ( $scope,   $filter,   PacingDashboard ) ->

#=====================================================================================================================
        getRandomValue = (min, max)-> Math.round(Math.random() * (max - min)) + min
#=====================================================================================================================

        $scope.timePeriods = []
        $scope.metrics = [
            {name: 'Pipeline', active: true, visibility: 'A'}
            {name: 'Revenue', active: true, visibility: 'B'}
            {name: 'Forecast Amt', active: true, visibility: 'C'}
            {name: 'This Qtr', active: true, visibility: '1'}
            {name: 'Last Qtr', active: true, visibility: '2'}
            {name: 'YoY', active: true, visibility: '3'}
        ]
        $scope.defaultTimePeriod = {id: null, name: 'Current'}
        $scope.filter =
            timePeriod: $scope.defaultTimePeriod

        $scope.pipelineRevenue = {}
        $scope.weeks = [1..13]
        $scope.currentWeek = 0

#=====================================================================================================================
        testData = {
            revenue: {
                current_quarter: [1..13].map -> getRandomValue(100000, 500000)
                previous_quarter: [1..13].map -> getRandomValue(250000, 350000)
                previous_year_quarter: [1..13].map -> getRandomValue(300000, 560000)
            }
            weighted_pipeline: {
                current_quarter: [1..13].map -> getRandomValue(100000, 500000)
                previous_quarter: [1..13].map -> getRandomValue(250000, 350000)
                previous_year_quarter: [1..13].map -> getRandomValue(300000, 560000)
            }
            sum_revenue_and_weighted_pipeline: {
                current_quarter: [1..13].map -> getRandomValue(100000, 500000)
                previous_quarter: [1..13].map -> getRandomValue(250000, 350000)
                previous_year_quarter: [1..13].map -> getRandomValue(300000, 560000)
            }
        }
#=====================================================================================================================
        (init = (query) ->
            PacingDashboard.pipeline_revenue(query).then (data) ->
                $scope.currentWeek = data.current_week
                $scope.timePeriods = data.time_periods
                $scope.pipelineRevenue = data.series.pipeline_and_revenue
#                drawChart(testData)
                drawChart($scope.pipelineRevenue)
                updateChartVisibility()
        )()

        $scope.setMetric = (metric) ->
            metric.active = !metric.active
            updateChartVisibility()
            return

        $scope.setFilter = (key, value) ->
            $scope.filter[key] = value
            applyFilter $scope.filter
            return

        applyFilter = (filter) ->
            query = {}
            query.time_period_id = filter.timePeriod.id if filter.timePeriod.id
            console.log query
            init query

        updateChartVisibility = ->
            visibility = _.reduce $scope.metrics, (mem, metric) ->
                if metric.active then mem + metric.visibility else mem || ''
            , ''
            angular.element('.graph').each (graph) ->
                graph = angular.element(this)
                graphVisibility = graph.data().visibility
                if _.indexOf(visibility, graphVisibility[0]) == -1 || _.indexOf(visibility, graphVisibility[1]) == -1
                    graph.animate {
                        opacity: 0
                    }, 500
                else
                    graph.animate {
                        opacity: 1
                    }, 500

        drawChart = (data) ->
            chartId = '#pipeline-revenue-chart'
            chartContainer = angular.element(chartId + '-container')
            delay = 1000
            duration = 2000
            margin =
                top: 10
                left: 45
                right: 10
                bottom: 60
            legendHeight = 50
            width = chartContainer.width() - margin.left - margin.right || 800
            height = 400


            svg = d3.select(chartId)
                .attr('width', width + margin.left + margin.right)
                .attr('height', height + margin.top + margin.bottom + legendHeight)
                .html('')
                .append('g')
                .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

            dataset = [
                {name: 'TQ-Pipeline', visibility: 'A1', values: data.weighted_pipeline.current_quarter}
                {name: 'LQ-Pipeline', visibility: 'A2', values: data.weighted_pipeline.previous_quarter}
                {name: 'YoY-Pipeline', visibility: 'A3', values: data.weighted_pipeline.previous_year_quarter}
                {name: 'TQ-Revenue', visibility: 'B1', values: data.revenue.current_quarter}
                {name: 'LQ-Revenue', visibility: 'B2', values: data.revenue.previous_quarter}
                {name: 'YoY-Revenue', visibility: 'B3', values: data.revenue.previous_year_quarter}
                {name: 'TQ-Forecast', visibility: 'C1', values: data.sum_revenue_and_weighted_pipeline.current_quarter}
                {name: 'LQ-Forecast', visibility: 'C2', values: data.sum_revenue_and_weighted_pipeline.previous_quarter}
                {name: 'YoY-Forecast', visibility: 'C3', values: data.sum_revenue_and_weighted_pipeline.previous_year_quarter}
            ]

            yMax = d3.max dataset, (item) -> d3.max item.values
            yMax = (yMax || 0) * 1.2

#            yParts = 5
#            yValues = [yParts..0].map (i) -> yMax / yParts * i

            x = d3.scale.ordinal().domain($scope.weeks).rangeBands([0, width])
            y = d3.scale.linear().domain([yMax, 0]).range([0, height])

            xAxis = d3.svg.axis().scale(x).orient('bottom')
                .outerTickSize(0)
                .innerTickSize(0)
                .tickPadding(10)
                .tickFormat (v, i) ->
                    if $scope.currentWeek == i + 1
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

            svg.append('line')
                .attr('class', 'week-line')
                .attr 'x1', x($scope.currentWeek) + x(2) / 2
                .attr 'y1', height
                .attr 'x2', x($scope.currentWeek) + x(2) / 2
                .attr 'y2', height
                .transition()
                .delay(delay / 2)
                .duration(duration / 2)
                .ease('linear')
                .attr('y1', 0)

            color = d3.scale.category10()

            graphLine = d3.svg.line()
                .x((value, i) -> x(i + 1) + x(2) / 2)
                .y((value, i) -> y(value))

            graphs = svg.selectAll('.graph')
                .data(dataset)
                .enter()
                .append('path')
                .attr('class', 'graph')
                .attr('data-visibility', (d) -> d.visibility)
                .style 'stroke', (d) -> color d.name
                .attr 'd', (d) ->
                    graphLine(d.values)

#            totalLength = 0
#            graphs.each ->
#                length = this.getTotalLength()
#                totalLength = length if length > totalLength

            graphs
                .attr 'stroke-dasharray', -> this.getTotalLength() + ' ' + this.getTotalLength()
                .attr 'stroke-dashoffset', -> this.getTotalLength()
                .transition()
                .delay(delay)
                .duration(duration)
                .ease('linear')
                .attr('stroke-dashoffset', 0)

            #legend
            legendData = [
                {color: 'gray', label: 'Goal'}
            ]
            _.forEach dataset.stages, (stage, i) ->
                if i is 0
                    legendData.push {color: colors[0], label: 'Won'}
                else
                    legendData.push {color: shadeColor(colors[1], 0.15 * (i - 1)), label: stage + '%'}

            legend = svg.append("g")
                .attr("transform", "translate(0, " + (height + 50) + ")")
                .attr("class", "legendTable")

            legendWithData = legend
                .selectAll('.legend')
                .data(dataset)
                .enter()
                .append('g')
                .attr('class', 'legend')
                .attr('transform', (d, i) -> 'translate(' + (i % 9) * 120 + ', 0)')
            legendWithData.append('rect')
                .attr 'x', 0
                .attr('y', (d, i) -> Math.floor(i / 9) * 20)
                .attr('width', 13)
                .attr('height', 13)
                .attr("rx", 4)
                .attr("ry", 4)
                .style 'fill', (d) -> color d.name
            legendWithData.append('text')
                .attr 'x', 20
                .attr('y', (d, i) -> Math.floor(i / 9) * 20 + 10)
                .attr('height', 30)
                .attr('width', 150)
                .text (d) -> d.name

    ]