@app.controller 'Agency360Controller',
    ['$scope', '$filter', '$timeout'
    ( $scope,   $filter,   $timeout ) ->

        FIRST_CHART_ID = '#spend-product-chart'
        SECOND_CHART_ID = '#spend-advertiser-chart'

        $scope.months = moment.monthsShort()

        randomValue = (min, max) -> Math.round(Math.random() * (max - min)) + min
        randomItem = (name) -> {name: name, values: $scope.months.map -> randomValue(5, 25) * 20000}

        products = [1..5].map (i) -> randomItem('Product ' + i)

        $timeout -> drawChart(products, FIRST_CHART_ID)

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

            currentMonth = $scope.currentMonth
            months = $scope.months

            dataset = data

            svg = d3.select(chartId)
                .attr('width', width + margin.left + margin.right)
                .attr('height', height + margin.top + margin.bottom)
                .html('')
                .append('g')
                .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')


            maxValue = (d3.max dataset, (item) -> d3.max item.values) || 0
            yMax = maxValue * 1.2

            x = d3.scale.ordinal().domain(months).rangeBands([0, width])
            y = d3.scale.linear().domain([yMax || 1, 0]).rangeRound([0, height])

            xAxis = d3.svg.axis().scale(x).orient('bottom')
                .outerTickSize(0)
                .innerTickSize(0)
                .tickPadding(10)
                .tickFormat (v, i) ->
                    if currentMonth == v
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

            if currentMonth
                svg.append('line')
                    .attr('class', 'month-line')
                    .attr 'x1', x(currentMonth)
                    .attr 'y1', height
                    .attr 'x2', x(currentMonth)
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
                .attr 'stroke', (d) -> d.color
                .attr 'stroke-dasharray', (d) -> d.dasharray
                .attr 'd', -> graphLine(_.map months, -> 0)
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