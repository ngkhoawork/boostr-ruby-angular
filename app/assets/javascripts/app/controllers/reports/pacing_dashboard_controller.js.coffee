@app.controller 'PacingDashboardController',
    ['$scope', '$filter', 'PacingDashboard', 'shadeColor'
    ( $scope,   $filter,   PacingDashboard,   shadeColor ) ->

        $scope.timePeriods = []
        $scope.metrics = [
            {name: 'Pipeline', active: true, visibility: 'A'}
            {name: 'Revenue', active: false, visibility: 'B'}
            {name: 'Forecast Amt', active: false, visibility: 'C'}
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

        colors = [
            shadeColor('#B3D776', 0)
            shadeColor('#B3D776', 30)
            shadeColor('#B3D776', 60)
            shadeColor('#5398CC', 0)
            shadeColor('#5398CC', 30)
            shadeColor('#5398CC', 60)
            shadeColor('#FF7E30', 0)
            shadeColor('#FF7E30', 30)
            shadeColor('#FF7E30', 60)
        ]

#=====================================================================================================================
        getRandomValue = (min, max)-> Math.round(Math.random() * (max - min)) + min
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
#            setTimeout ->
#                $scope.currentWeek = getRandomValue(1, 13)
#                drawChart(testData, '#pipeline-revenue-chart')
#                updateChartVisibility()
#            return
            PacingDashboard.pipeline_revenue(query).then (data) ->
                $scope.currentWeek = data.current_week
                $scope.timePeriods = data.time_periods
                $scope.pipelineRevenue = data.series.pipeline_and_revenue
#                drawChart(testData)
                drawChart($scope.pipelineRevenue, '#pipeline-revenue-chart')
                drawChart($scope.pipelineRevenue, '#activity-new-chart')
                drawChart($scope.pipelineRevenue, '#activity-won-chart')
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

        drawChart = (data, chartId) ->
            chartContainer = angular.element(chartId + '-container')
            delay = 1000
            duration = 2000
            margin =
                top: 10
                left: 45
                right: 10
                bottom: 40
            width = chartContainer.width() - margin.left - margin.right || 800
            height = 400


            svg = d3.select(chartId)
                .attr('width', width + margin.left + margin.right)
                .attr('height', height + margin.top + margin.bottom)
                .html('')
                .append('g')
                .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

            dataset = [
                {name: 'TQ-Pipeline', color: shadeColor('#B3D776', 0), visibility: 'A1', values: data.weighted_pipeline.current_quarter}
                {name: 'LQ-Pipeline', color: shadeColor('#B3D776', 0.3), visibility: 'A2', values: data.weighted_pipeline.previous_quarter}
                {name: 'YoY-Pipeline', color: shadeColor('#B3D776', 0.6), visibility: 'A3', values: data.weighted_pipeline.previous_year_quarter}
                {name: 'TQ-Revenue', color: shadeColor('#5398CC', 0), visibility: 'B1', values: data.revenue.current_quarter}
                {name: 'LQ-Revenue', color: shadeColor('#5398CC', 0.3), visibility: 'B2', values: data.revenue.previous_quarter}
                {name: 'YoY-Revenue', color: shadeColor('#5398CC', 0.6), visibility: 'B3', values: data.revenue.previous_year_quarter}
                {name: 'TQ-Forecast', color: shadeColor('#FF7E30', 0), visibility: 'C1', values: data.sum_revenue_and_weighted_pipeline.current_quarter}
                {name: 'LQ-Forecast', color: shadeColor('#FF7E30', 0.3), visibility: 'C2', values: data.sum_revenue_and_weighted_pipeline.previous_quarter}
                {name: 'YoY-Forecast', color: shadeColor('#FF7E30', 0.6), visibility: 'C3', values: data.sum_revenue_and_weighted_pipeline.previous_year_quarter}
            ]

            yMax = d3.max dataset, (item) -> d3.max item.values
            yMax = (yMax || 0) * 1.2

#            yParts = 5
#            yValues = [yParts..0].map (i) -> yMax / yParts * i

            x = d3.scale.ordinal().domain(['Week'].concat $scope.weeks).rangePoints([0, width - width / $scope.weeks.length])
            y = d3.scale.linear().domain([yMax, 0]).range([0, height])

            xAxis = d3.svg.axis().scale(x).orient('bottom')
                .outerTickSize(0)
                .innerTickSize(0)
                .tickPadding(10)
                .tickFormat (v, i) ->
                    if $scope.currentWeek == i
                        d3.select(this)
                            .style 'font-weight', 'bold'
                            .style 'font-size', '12px'
#                    'Week ' + v
                    v
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
                .attr 'x1', x($scope.currentWeek)
                .attr 'y1', height
                .attr 'x2', x($scope.currentWeek)
                .attr 'y2', height
                .transition()
                .delay(delay / 2)
                .duration(duration / 2)
                .ease('linear')
                .attr('y1', 0)

#            color = d3.scale.category10()

            graphLine = d3.svg.line()
                .x((value, i) -> x(i + 1))
                .y((value, i) -> y(value))

            graphs = svg.selectAll('.graph')
                .data(dataset)
                .enter()
                .append('path')
                .attr('class', 'graph')
                .attr('data-visibility', (d) -> d.visibility)
                .style 'stroke', (d) -> d.color
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
            legendContainer = d3.select(chartId + '-container').append('div')
                .attr('class', 'legend-container')
                .style 'margin-left', margin.left + 'px'
            legend = legendContainer
                .selectAll('.legend')
                .data(dataset)
                .enter()
                .append('div')
                .attr('class', 'legend')
            legend.append('div')
                .attr('class', 'legend-icon')
                .style 'background-color', (d) -> d.color
            legend.append('span')
                .attr 'class', 'legend-text'
                .html (d) -> d.name

    ]