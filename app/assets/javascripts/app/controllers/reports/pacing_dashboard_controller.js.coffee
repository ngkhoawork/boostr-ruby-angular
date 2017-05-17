@app.controller 'PacingDashboardController',
    ['$scope', '$filter', 'PacingDashboard', 'shadeColor'
    ( $scope,   $filter,   PacingDashboard,   shadeColor ) ->

        $scope.timePeriods = []
        $scope.teams = []
        $scope.sellers = []
        $scope.products = []
        $scope.metrics = [
            {name: 'Pipeline', active: true, visibility: 'A'}
            {name: 'Revenue', active: true, visibility: 'B'}
            {name: 'Forecast Amt', active: true, visibility: 'C'}
            {name: 'This Qtr', active: true, visibility: '1'}
            {name: 'Last Qtr', active: true, visibility: '2'}
            {name: 'YoY', active: true, visibility: '3'}
        ]
        $scope.defaultFilter =
            timePeriod: {id: null, name: 'Current'}
            team: {id: null, name: 'All'}
            seller: {id: null, name: 'All'}
            product: {id: null, name: 'All'}
        $scope.filter = angular.copy $scope.defaultFilter

        $scope.pipelineRevenue = {}
        $scope.newDeals = {}
        $scope.wonDeals = {}
        $scope.weeks = [1..13]
        $scope.currentWeek = 0

        (getPipelineRevenueData = (query) ->
            PacingDashboard.pipeline_revenue(query).then (data) ->
                $scope.currentWeek = data.current_week
                $scope.timePeriods = data.time_periods
                $scope.pipelineRevenue = data.series.pipeline_and_revenue
                drawChart($scope.pipelineRevenue, '#pipeline-revenue-chart')
                updateChartVisibility()
        )()

        (getNewWonDealsData = (query) ->
            PacingDashboard.activity_pacing(query).then (data) ->
                $scope.teams = data.teams
                $scope.sellers = data.sellers
                $scope.products = data.products
                $scope.newDeals = data.series.new_deals
                $scope.wonDeals = data.series.won_deals
                drawChart($scope.newDeals, '#activity-new-chart')
                drawChart($scope.wonDeals, '#activity-won-chart')
        )()

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

            query.team_id = f.team.id if f.team.id
            query.seller_id = f.seller.id if f.seller.id
            query.product_id = f.product.id if f.product.id
            getNewWonDealsData query

        updateChartVisibility = ->
            visibility = _.reduce $scope.metrics, (mem, metric) ->
                if metric.active then mem + metric.visibility else mem || ''
            , ''
            angular.element('.graph').each (graph) ->
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
                when '#pipeline-revenue-chart'
                    [
                        {name: 'TQ-Pipeline',  color: shadeColor(c(0), 0),   dasharray: 'none',   visibility: 'A1', values: data.weighted_pipeline.current_quarter}
                        {name: 'LQ-Pipeline',  color: shadeColor(c(0), 0.3), dasharray: 'none',   visibility: 'A2', values: data.weighted_pipeline.previous_quarter}
                        {name: 'YoY-Pipeline', color: shadeColor(c(0), 0.6), dasharray: 'none',   visibility: 'A3', values: data.weighted_pipeline.previous_year_quarter}
                        {name: 'TQ-Revenue',   color: shadeColor(c(1), 0),   dasharray: '4, 4',   visibility: 'B1', values: data.revenue.current_quarter}
                        {name: 'LQ-Revenue',   color: shadeColor(c(1), 0.3), dasharray: '4, 4',   visibility: 'B2', values: data.revenue.previous_quarter}
                        {name: 'YoY-Revenue',  color: shadeColor(c(1), 0.6), dasharray: '4, 4',   visibility: 'B3', values: data.revenue.previous_year_quarter}
                        {name: 'TQ-Forecast',  color: shadeColor(c(2), 0),   dasharray: '12, 12', visibility: 'C1', values: data.sum_revenue_and_weighted_pipeline.current_quarter}
                        {name: 'LQ-Forecast',  color: shadeColor(c(2), 0.3), dasharray: '12, 12', visibility: 'C2', values: data.sum_revenue_and_weighted_pipeline.previous_quarter}
                        {name: 'YoY-Forecast', color: shadeColor(c(2), 0.6), dasharray: '12, 12', visibility: 'C3', values: data.sum_revenue_and_weighted_pipeline.previous_year_quarter}
                    ]
                when '#activity-new-chart'
                    [
                        {name: 'TQ-New Deals',  color: c(1), dasharray: 'none',   values: data.current_quarter}
                        {name: 'LQ-New Deals',  color: c(1), dasharray: '4, 4',   values: data.previous_quarter}
                        {name: 'YoY-New Deals', color: c(1), dasharray: '12, 12', values: data.previous_year_quarter}
                    ]
                when '#activity-won-chart'
                    [
                        {name: 'TQ-Won Deals',  color: c(1), dasharray: 'none',   values: data.current_quarter}
                        {name: 'LQ-Won Deals',  color: c(1), dasharray: '4, 4',   values: data.previous_quarter}
                        {name: 'YoY-Won Deals', color: c(1), dasharray: '12, 12', values: data.previous_year_quarter}
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


            svg = d3.select(chartId)
                .attr('width', width + margin.left + margin.right)
                .attr('height', height + margin.top + margin.bottom)
                .html('')
                .append('g')
                .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

            dataset = transformChartData(data, chartId)

            yMax = d3.max dataset, (item) -> d3.max item.values
            yMax = yMax * 1.2 || 0

            x = d3.scale.ordinal().domain(['Week'].concat $scope.weeks).rangePoints([0, width - width / $scope.weeks.length])
            y = d3.scale.linear().domain([yMax || 1, 0]).rangeRound([0, height])

            xAxis = d3.svg.axis().scale(x).orient('bottom')
                .outerTickSize(0)
                .innerTickSize(0)
                .tickPadding(10)
                .tickFormat (v, i) ->
                    if $scope.currentWeek == i
                        d3.select(this)
                            .style 'font-weight', 'bold'
                            .style 'font-size', '12px'
                    v
            yAxis = d3.svg.axis().scale(y).orient('left')
                .innerTickSize(-width)
                .tickPadding(10)
                .outerTickSize(0)
                .ticks(if yMax > 6 then 6 else yMax || 1)
                .tickFormat (v) ->
                    if chartId == '#activity-new-chart' then return v
                    $filter('formatMoney')(v)
            yAxis.tickValues([0]) if yMax == 0

            svg.append('g').attr('class', 'axis').attr('transform', 'translate(0,' + height + ')').call xAxis
            svg.append('g').attr('class', 'axis').call yAxis

            if $scope.currentWeek
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

            graphLine = d3.svg.line()
                .x((value, i) -> x(i + 1))
                .y((value, i) -> y(value))

            graphsContainer = svg.append('g')
                .attr('class', 'graphs-container')
#                .attr('clip-path', 'url(#clip)')

            graphs = graphsContainer.selectAll('.graph')
                .data(dataset)
                .enter()
                .append('path')
                .attr('class', 'graph')
                .attr('data-visibility', (d) -> d.visibility)
                .style 'stroke', (d) -> d.color
                .attr 'd', -> graphLine(_.map $scope.weeks, -> 0)
                .transition()
                .duration(duration)
                .attr 'd', (d) -> graphLine(d.values)

            graphs
                .attr 'stroke-dasharray', (d) -> d.dasharray

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