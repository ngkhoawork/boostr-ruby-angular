@app.controller 'PacingDashboardController',
    ['$scope', '$filter', 'PacingDashboard', 'shadeColor'
    ( $scope,   $filter,   PacingDashboard,   shadeColor ) ->

        $scope.timePeriods = []
        $scope.metrics = [
            {name: 'Pipeline', active: true, visibility: 'A'}
            {name: 'Revenue', active: true, visibility: 'B'}
            {name: 'Forecast Amt', active: true, visibility: 'C'}
            {name: 'This Qtr', active: true, visibility: '1'}
            {name: 'Last Qtr', active: true, visibility: '2'}
            {name: 'Last Year', active: true, visibility: '3'}
        ]
        $scope.defaultFilter =
            timePeriod: {id: null, name: 'Current'}

        $scope.filter = angular.copy $scope.defaultFilter

        $scope.pipelineRevenue = {}
        $scope.newDeals = {}
        $scope.wonDeals = {}
        $scope.weekShift = 8
        $scope.weeks = [1..13 + $scope.weekShift]
        $scope.dealWeeks = [1..13]
        $scope.currentWeek = null
        $scope.maxQuota = null

        FIRST_CHART_ID = '#pipeline-revenue-chart'
        SECOND_CHART_ID = '#activity-new-chart'
        THIRD_CHART_ID = '#activity-won-chart'

        (getPipelineRevenueData = (query) ->
            PacingDashboard.pipeline_revenue(query).then (data) ->
                $scope.currentWeek = data.current_week
                $scope.maxQuota = data.max_quota
                $scope.timePeriods = data.time_periods
                $scope.pipelineRevenue = data.series.pipeline_and_revenue
                drawChart($scope.pipelineRevenue, FIRST_CHART_ID)
                updateChartVisibility()
        )()

        (getNewWonDealsData = (query) ->
            PacingDashboard.activity_pacing(query).then (data) ->
                $scope.currentWeek = data.current_week
                $scope.newDeals = data.series.new_deals
                $scope.wonDeals = data.series.won_deals
                drawChart($scope.newDeals, SECOND_CHART_ID)
                drawChart($scope.wonDeals, THIRD_CHART_ID)
        )()

        $scope.isNumber = _.isNumber

        $scope.setMetric = (metric) ->
            metric.active = !metric.active
            updateChartVisibility()
            return

        $scope.setFilter = (key, value) ->
            f = $scope.filter
            f[key] = value
            query = {}
            query.time_period_id = f.timePeriod.id if f.timePeriod.id
            getPipelineRevenueData query if key == 'timePeriod'
            getNewWonDealsData query

        updateChartVisibility = ->
            visibility = _.reduce $scope.metrics, (mem, metric) ->
                if metric.active then mem + metric.visibility else mem || ''
            , ''
            angular.element('#pipeline-revenue-chart .graph').each (graph) ->
                graph = angular.element(this)
                graphVisibility = graph.data().visibility || []
                if _.indexOf(visibility, graphVisibility[0]) == -1 || _.indexOf(visibility, graphVisibility[1]) == -1
                    graph.animate {
                        opacity: 0
                    }, 500
                else   
                    graph.animate {
                        opacity: 1
                    }, 500

        transformChartData = (data, chartId) ->
            c = d3.scale.category10()
            c(0) #blue
            c(2) #green
            c(1) #oranbe
            switch chartId
                when FIRST_CHART_ID
                    [
                        {name: 'TQ-Pipeline',  color: shadeColor(c(0), 0),   dasharray: 'none',   visibility: 'A1', values: data.weighted_pipeline.current_quarter}
                        {name: 'LQ-Pipeline',  color: shadeColor(c(0), 0.3), dasharray: '12, 12',   visibility: 'A2', values: data.weighted_pipeline.previous_quarter}
                        {name: 'LY-Pipeline', color: shadeColor(c(0), 0.6), dasharray: '4, 4',   visibility: 'A3', values: data.weighted_pipeline.previous_year_quarter}
                        {name: 'TQ-Revenue',   color: shadeColor(c(1), 0),   dasharray: 'none',   visibility: 'B1', values: data.revenue.current_quarter}
                        {name: 'LQ-Revenue',   color: shadeColor(c(1), 0.3), dasharray: '12, 12',   visibility: 'B2', values: data.revenue.previous_quarter}
                        {name: 'LY-Revenue',  color: shadeColor(c(1), 0.6), dasharray: '4, 4',   visibility: 'B3', values: data.revenue.previous_year_quarter}
                        {name: 'TQ-Forecast',  color: shadeColor(c(2), 0),   dasharray: 'none', visibility: 'C1', values: data.sum_revenue_and_weighted_pipeline.current_quarter}
                        {name: 'LQ-Forecast',  color: shadeColor(c(2), 0.3), dasharray: '12, 12', visibility: 'C2', values: data.sum_revenue_and_weighted_pipeline.previous_quarter}
                        {name: 'LY-Forecast', color: shadeColor(c(2), 0.6), dasharray: '4, 4', visibility: 'C3', values: data.sum_revenue_and_weighted_pipeline.previous_year_quarter}
                    ]
                when SECOND_CHART_ID
                    [
                        {name: 'TQ-New Deals',  color: c(1), dasharray: 'none',   values: data.current_quarter}
                        {name: 'LQ-New Deals',  color: c(1), dasharray: '12, 12',   values: data.previous_quarter}
                        {name: 'LY-New Deals', color: c(1), dasharray: '4, 4', values: data.previous_year_quarter}
                    ]
                when THIRD_CHART_ID
                    [
                        {name: 'TQ-Won Deals',  color: c(1), dasharray: 'none',   values: data.current_quarter}
                        {name: 'LQ-Won Deals',  color: c(1), dasharray: '12, 12',   values: data.previous_quarter}
                        {name: 'LY-Won Deals', color: c(1), dasharray: '4, 4', values: data.previous_year_quarter}
                    ]

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

            currentWeek = $scope.currentWeek
            weekShift = if chartId == FIRST_CHART_ID then $scope.weekShift else 0
            weeks = if chartId == FIRST_CHART_ID then $scope.weeks else $scope.dealWeeks

            dataset = transformChartData(data, chartId)

            svg = d3.select(chartId)
                .attr('width', width + margin.left + margin.right)
                .attr('height', height + margin.top + margin.bottom)
                .html('')
                .append('g')
                .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')


            maxValue = (d3.max dataset, (item) -> d3.max item.values) || 0
            yMax = maxValue * 1.2

            x = d3.scale.ordinal().domain(['Week'].concat weeks).rangePoints([0, width - width / weeks.length])
            y = d3.scale.linear().domain([yMax || 1, 0]).rangeRound([0, height])

            xAxis = d3.svg.axis().scale(x).orient('bottom')
                .outerTickSize(0)
                .innerTickSize(0)
                .tickPadding(10)
                .tickFormat (v, i) ->
                    if chartId == FIRST_CHART_ID && typeof v == 'number'
                        v = if v <= weekShift then v - weekShift - 1 else v - weekShift
                    if currentWeek == v
                        d3.select(this)
                            .style 'font-weight', 'bold'
                            .style 'font-size', '12px'
                    return v
            yAxis = d3.svg.axis().scale(y).orient('left')
                .innerTickSize(-width)
                .tickPadding(10)
                .outerTickSize(0)
                .ticks(if yMax > 6 then 6 else yMax || 1)
                .tickFormat (v) ->
                    if chartId == SECOND_CHART_ID then return v
                    $filter('formatMoney')(v)
            yAxis.tickValues([0]) if yMax == 0

            svg.append('g').attr('class', 'axis').attr('transform', 'translate(0,' + height + ')').call xAxis
            svg.append('g').attr('class', 'axis').call yAxis

            if currentWeek
                svg.append('line')
                    .attr('class', 'week-line')
                    .attr 'x1', x(currentWeek + weekShift)
                    .attr 'y1', height
                    .attr 'x2', x(currentWeek + weekShift)
                    .attr 'y2', height
                    .transition()
                    .delay(delay / 2)
                    .duration(duration / 2)
                    .ease('linear')
                    .attr('y1', 0)

            if chartId == FIRST_CHART_ID && !_.isUndefined $scope.maxQuota
                svg.append('line')
                    .attr('class', 'max-line')
                    .attr 'x1', 0
                    .attr 'y1', y $scope.maxQuota
                    .attr 'x2', 0
                    .attr 'y2', y $scope.maxQuota
                    .transition()
                    .delay(delay / 2)
                    .duration(duration / 2)
                    .ease('linear')
                    .attr('x2', width)

            graphLine = d3.svg.line()
                .x((value, i) -> x(i + 1))
                .y((value, i) -> y(value))
                .defined((value, i) -> _.isNumber value)

            graphsContainer = svg.append('g')
                .attr('class', 'graphs-container')
#                .attr('clip-path', 'url(#clip)')

            graphs = graphsContainer.selectAll('.graph')
                .data(dataset)
                .enter()
                .append('path')
                .attr('class', 'graph')
                .attr('data-visibility', (d) -> d.visibility)
                .attr 'stroke', (d) -> d.color
                .attr 'stroke-dasharray', (d) -> d.dasharray
                .attr 'd', -> graphLine(_.map weeks, -> 0)
                .transition()
                .duration(duration)
                .attr 'd', (d) -> graphLine(d.values)

            #legend
            legendContainer = d3.select(chartId + '-container .legend-container')
                .html('')
                .style 'margin-left', margin.left + 'px'
            legend = legendContainer
                .selectAll('.legend')
                .data(dataset)
                .enter()
                .append('div')
                .attr('class', 'legend')
#            legend.append('div')
#                .attr('class', 'legend-icon')
#                .style 'background-color', (d) -> d.color
            legend.append('svg')
                .style 'width', '36'
                .style 'height', '4px'
                .style 'margin-right', '8px'
                .append('line')
                .attr 'stroke-dasharray', (d) -> d.dasharray
                .style 'stroke', (d) -> d.color
                .style 'stroke-width', 3
                .attr 'x1', 0
                .attr 'y1', 2
                .attr 'x2', 36
                .attr 'y2', 2
            legend.append('span')
                .attr 'class', 'legend-text'
                .html (d) -> d.name

    ]