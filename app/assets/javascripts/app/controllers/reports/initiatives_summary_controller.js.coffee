@app.controller 'InitiativesSummaryController',
    ['$scope', '$filter', 'Initiatives', 'shadeColor',
        ($scope, $filter, Initiatives, shadeColor) ->
            colors = ['#8CC135', '#FF7200']

            $scope.filter = 'open'
            $scope.setFilter = (v) ->
                $scope.filter = v

            Initiatives.summaryOpen().then (data) ->
                console.log data

            Initiatives.summaryClosed().then (data) ->
                console.log data

            #==================================================
            data = []
            for i in [1..Math.round(Math.random() * 8) + 2]
                arr = []
                for j in [1..Math.round(Math.random() * 4) + 2]
                    arr.push Math.round(Math.random() * 2000000) + 100000
                arr[0] *= 1.5
                statuses = ['Active', 'Complete']
                data.push
                    name: 'Initiative ' + i
                    numbers: arr
                    percent: Math.round(Math.random() * 100)
                    status: statuses[Math.round(Math.random())]

            $scope.initiatives = data
            #======================================================

            drawChart = (data, chartId) ->
                delay = 500
                duration = 1000
                margin =
                    top: 50
                    left: 100
                    right: 24
                    bottom: 24
                barHeight = 35
                barMargin = 25
                legendHeight = 50
                width = 980
                height = data.length * (barHeight + barMargin)

                dataset = []
                data.forEach (initiative, i) ->
                    initiative.numbers.forEach (number, j) ->
                        if !Array.isArray dataset[j] then dataset[j] = []
                        dataset[j][i] =
                            x: initiative.name
                            y: number
                        for item, k in data
                            if item.numbers[j] is undefined
                                dataset[j][k] =
                                    x: item.name
                                    y: 0

                stack = d3.layout.stack()
                stack dataset

                dataset = dataset.map (group) ->
                    group.map (d) ->
                            x: d.y
                            y: d.x
                            x0: d.y0

                svg = d3.select(chartId)
                    .attr('width', width + margin.left + margin.right)
                    .attr('height', height + margin.top + margin.bottom + legendHeight)
                    .append('g')
                    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
                xMax = d3.max(dataset, (group) ->
                    d3.max group, (d) ->
                        d.x + d.x0
                )
                x = d3.scale.linear().domain([
                    0
                    xMax
                ]).range([
                    0
                    width
                ])
                items = dataset[0].map((d) ->
                    d.y
                )
                y = d3.scale.ordinal().domain(items).rangeRoundBands([0, height])
                xAxis = d3.svg.axis()
                    .scale(x).orient('bottom')
                    .tickFormat (v) ->
                        $filter('formatMoney')(v)
                yAxis = d3.svg.axis().scale(y).orient('left')
                groups = svg.selectAll('g')
                    .data(dataset)
                    .enter()
                    .append('g')
                    .style 'fill', (d, i) ->
                        if i is 0 then colors[0] else shadeColor colors[1], 0.15 * (i - 1)
                rects = groups.selectAll('rect').data((d) -> d)
                .enter().append('rect')
                .attr 'x', 0
                .attr 'y', (d, i) ->
                    (y d.y) + y.rangeBand() / 2 - barHeight / 2
                .attr 'width', 0
                .attr 'height', barHeight
                .transition().delay(delay).duration(duration)
                .attr 'x', (d) ->
                    x d.x0
                .attr 'width', (d) ->
                    x d.x

                svg.append('g').attr('class', 'axis').attr('transform', 'translate(0,' + height + ')').call xAxis
                svg.append('g').attr('class', 'axis').call yAxis

                legendData = [
                    {color: colors[0], label: 'Goal'}
                    {color: colors[1], label: '?'}
                ]

                #legend
                legend = svg.append("g")
                    .attr("transform", "translate(0, " + (height + 50) + ")")
                    .attr("class", "legendTable")
                    .selectAll('#inactive-chart' + ' .legend')
                    .data(legendData)
                    .enter()
                    .append('g')
                    .attr('class', 'legend')
                    .attr('transform', (d, i) -> 'translate(' + (i % 6) * 100 + ', 0)')
                legend.append('rect')
                    .attr 'x', 0
#                    .attr('x', (d, i) -> (i % 6) * 70)
                    .attr('y', (d, i) -> Math.floor(i / 6) * 20)
                    .attr('width', 13)
                    .attr('height', 13)
                    .attr("rx", 4)
                    .attr("ry", 4)
                    .style 'fill', (d) -> d.color
                legend.append('text')
                    .attr 'x', 20
#                    .attr('x', (d, i) -> (i % 6) * 70 + 20)
                    .attr('y', (d, i) -> Math.floor(i / 6) * 20 + 10)
                    .attr('height', 30)
                    .attr('width', 150)
                    .text (d) -> d.label


            drawChart(data, '#initiatives-summary-chart')
    ]