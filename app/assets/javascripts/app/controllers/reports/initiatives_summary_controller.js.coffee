@app.controller 'InitiativesSummaryController',
    ['$scope', '$timeout', '$filter', 'Initiatives', 'shadeColor',
        ($scope, $timeout, $filter, Initiatives, shadeColor) ->
            colors = ['#8CC135', '#FF7200']
            $scope.filter = 'open'
            $scope.selectedInitiative = null
            $scope.dataLoading = false
            $scope.setFilter = (v) ->
                $scope.filter = v
                $scope.init()

            $scope.init = () ->
                $scope.dataLoading = true
                Initiatives.all($scope.filter).then (data) ->
                    $scope.initiatives = data
                    stages = []
                    _.forEach data, (initiative) ->
                        if initiative.chart_data
                            for stage, value of initiative.chart_data
                                if stages.indexOf(stage) == -1 then stages.push stage
                    stages.sort (n1, n2) ->
                        if Number n1 < Number n2 then return 1
                        if Number n1 > Number n2 then return -1
                        return 0

                    data.stages = stages
                    drawChart(data, '#initiatives-summary-chart')
                    $scope.dataLoading = false
            $scope.init()

            $scope.selectInitiative = (initiative) ->
                if !initiative then return
                if $scope.selectedInitiative && initiative.id == $scope.selectedInitiative.id
                    $scope.selectedInitiative = null
                else
                    $scope.selectedInitiative = initiative
                    getDeals initiative, () ->
                        $timeout () ->
                            angular.element('html, body').scrollTop angular.element("#selected-initiative").offset().top


            getDeals = (initiative, callback) ->
                Initiatives.deals(initiative.id).then (data) ->
                    initiative.deals = data
                    callback()

            drawChart = (data, chartId) ->
                if !data || !data.length then return
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
                    data.stages.forEach (stage, j) ->
                        number = initiative.chart_data[stage]
                        if !Array.isArray dataset[j] then dataset[j] = []
                        if number is undefined then return
                        dataset[j][i] =
                            x: initiative.name
                            y: number
                        for item, k in data
                            if item.chart_data[stage] is undefined
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
                    .html('')
                    .append('g')
                    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
                xMax = d3.max(dataset, (group) ->
                    d3.max group, (d) ->
                        d.x + d.x0
                )
                _.forEach data, (d) ->
                    if d.goal > xMax then xMax = d.goal

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

                goalLines = svg.append('g')
                goalLines.selectAll('line')
                    .data(data)
                    .enter()
                    .append('line')
                    .attr('class', 'goal-line')
                    .attr 'y1', (d) ->
                        (y d.name) + y.rangeBand() / 2 - barHeight / 1.3
                    .attr 'y2', (d) ->
                        (y d.name) + y.rangeBand() / 2 - barHeight / 1.3
                    .attr 'x1', (d) ->
                        x d.goal
                    .attr 'x2', (d) ->
                        x d.goal
                    .transition().delay(delay * 2).duration(duration / 2)
                    .attr 'y2', (d) ->
                        (y d.name) + y.rangeBand() / 2 + barHeight / 1.3


                svg.append('g').attr('class', 'axis').attr('transform', 'translate(0,' + height + ')').call xAxis
                svg.append('g').attr('class', 'axis').call yAxis

                #legend
                legendData = [
                    {color: 'gray', label: 'Goal'}
                ]
                _.forEach data.stages, (stage, i) ->
                    if i is 0
                     legendData.push {color: colors[0], label: 'Won'}
                    else
                     legendData.push {color: shadeColor(colors[1], 0.15 * (i - 1)), label: stage + '%'}

                legend = svg.append("g")
                    .attr("transform", "translate(0, " + (height + 50) + ")")
                    .attr("class", "legendTable")

                goalLegend = legend
                    .append('g')
                    .attr('class', 'legend')
                goalLegend
                    .append('line')
                        .attr('class', 'goal-line')
                        .attr 'x1', 0
                        .attr('y1', 5)
                        .attr("x2", 26)
                        .attr("y2", 5)
                goalLegend
                    .append('text')
                        .attr 'x', 34
                        .attr('y', 10)
                        .attr('height', 30)
                        .attr('width', 150)
                        .text legendData[0].label

                legendWithData = legend
                    .selectAll('.legend')
                    .data(legendData)
                    .enter()
                    .append('g')
                    .attr('class', 'legend')
                    .attr('transform', (d, i) -> 'translate(' + (i % 6) * 100 + ', 0)')
                legendWithData.append('rect')
                    .attr 'x', 0
                    .attr('y', (d, i) -> Math.floor(i / 6) * 20)
                    .attr('width', 13)
                    .attr('height', 13)
                    .attr("rx", 4)
                    .attr("ry", 4)
                    .style 'fill', (d) -> d.color
                legendWithData.append('text')
                    .attr 'x', 20
                    .attr('y', (d, i) -> Math.floor(i / 6) * 20 + 10)
                    .attr('height', 30)
                    .attr('width', 150)
                    .text (d) -> d.label
    ]