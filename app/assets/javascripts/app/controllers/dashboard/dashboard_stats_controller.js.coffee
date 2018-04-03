@app.controller 'DashboardStatsController',
    ['$scope', '$document', 'shadeColor', 'localStorageService'
        ($scope, $document, shadeColor, LS) ->
            $scope.$watch '$parent.dashboard', (dashboard)->
                $scope.pageName = 'dashboardMyStats'

                if !dashboard then return
                $scope.forecast = [
                    dashboard.forecast
                    dashboard.next_quarter_forecast
                    dashboard.this_year_forecast
                ]
                setCurrenStatsTab()

            setCurrenStatsTab = ->
                statTab = LS.get($scope.pageName) || 0
                $scope.setStats(statTab)

            $scope.setStats = (n) ->
                return if $scope.qtr is n

                LS.set($scope.pageName, n)
                $scope.qtr = n
                $scope.stats = $scope.forecast[n]

                return if !$scope.stats

                updateProgressCircle($scope.stats.percent_to_quota)
                updateForecastChart($scope.stats)

            interval = null
            updateProgressCircle = (p) ->
                p = Math.round(p)
                animationDuration = 2000
                width = 150
                height = 150
                tau = 2 * Math.PI
                arc = d3.svg.arc()
                    .innerRadius(62)
                    .outerRadius(65)
                    .startAngle(0)
                svg = d3.select("#progress-circle")
                    .style('width': width + 'px')
                    .style('height': height + 'px')
                svg.html('')
                g = svg.append('g')
                    .attr('transform', 'translate(' + width / 2 + ',' + height / 2 + ')')
                background = g.append('path')
                    .datum(endAngle: tau)
                    .style('fill', '#EEE')
                    .attr('d', arc)
                foreground = g.append('path')
                    .datum(endAngle: 0)
                    .attr('d', arc)
                point = svg.append('circle')
                    .attr('r', 5)
                    .attr('transform', 'translate(75, 11.5)')

                arcTween = (newAngle) ->
                    (d) ->
                        interpolate = d3.interpolate(d.endAngle, newAngle)
                        (t) ->
                            d.endAngle = interpolate(t)
                            arc d

                translateFn = (newAngle) ->
                    () ->
                        (t) ->
                            rotation_radius = 63.5
                            t_angle = newAngle * t - Math.PI / 2
                            t_x = rotation_radius * Math.cos(t_angle)
                            t_y = rotation_radius * Math.sin(t_angle)
                            'translate(' + (width / 2 + t_x) + ',' + (height / 2 + t_y) + ')'
                endAngle = tau / 100 * p
                foreground.transition().duration(animationDuration).attrTween('d', arcTween(endAngle))
                point.transition().duration(animationDuration).attrTween('transform', translateFn(endAngle))

                i = 0
                progressNumber = $document.find('#progress-number')
                clearInterval(interval)
                progressNumber.html(i + '%')
                interval = setInterval (->
                    if i is p || i >= animationDuration / 4
                        clearInterval(interval)
                        i = p
                    progressNumber.html(i + '%')
                    i++
                ), animationDuration / p

            updateForecastChart = (stats) ->
                statsContainer = $document.find('#stats')[0]
                revenueColor = '#8CC135'
                stageColor = '#3498DB'
                gapColor = '#FF7200'
                data = [
                    name: 'Revenue', value: stats.revenue, color: revenueColor
                ]
                angular.copy(stats.stages).reverse().forEach (s, i) ->
                    value = stats.weighted_pipeline_by_stage[s.id] || 0
                    if value > 0
                        data.push
                            name: s.probability + '%'
                            value: Math.round(parseInt(value))
                            color: shadeColor(stageColor, 0.8 / (stats.stages.length - 1) * i)
                data.push
                    name: 'Gap', value: Math.round(parseInt(stats.gap_to_quota)) , color: gapColor

                delay = 500
                duration = 2000
                margin =
                    top: 20
                    right: 30
                    bottom: 30
                    left: 80
                width = statsContainer.clientWidth - 40 - (margin.left) - (margin.right)
                height = 450 - (margin.top) - (margin.bottom)
                padding = 0.3

                cumulative = 0
                i = 0
                while i < data.length
                    data[i].start = cumulative
                    cumulative += data[i].value
                    data[i].end = cumulative
                    i++
                x = d3.scale.ordinal().rangeRoundBands([
                    0
                    width
                ], padding)
                y = d3.scale.linear().range([
                    height
                    0
                ])

                maxValue = 0
                gapLine = 0
                data.forEach((d) ->
                    maxValue = maxValue + if d.value > 0 then d.value else 0
                    gapLine += d.value
                    if d.name is 'Gap' and d.value < 0 then d.end = d.start
                )
                cap = maxValue * 1.15
                if gap < 0 then gap = 0
                ticksArr = []
                if maxValue > 0
                    step = (() ->
                        if cap <= 10000 then return 1000
                        Math.ceil((cap / 10000) / 6) * 10000
                    )()
                    for i in [0..cap + step] by step
                        ticksArr.push(i)
                        if i >= cap
                            cap = i
                            break
                else
                    ticksArr = [0]


                xAxis = d3.svg.axis().scale(x).orient('bottom')
                    .innerTickSize(0)
                    .tickPadding(10)
                    .outerTickSize(0)
                yAxis = d3.svg.axis().scale(y).orient('left')
                    .tickFormat (d) ->
                        dollarFormatter d
                    .innerTickSize(-width)
                    .tickPadding(10)
                    .outerTickSize(0)
                    .tickValues(ticksArr)

                svg = d3.select('#forecast-chart')
                    .attr('width', width + margin.left + margin.right)
                    .attr('height', height + margin.top + margin.bottom)
                    .style('height', height + margin.top + margin.bottom + 'px')
                svg.html('')
                chart = svg.append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

                dollarFormatter = (n) ->
                    n = Math.round(n)
                    result = n
    #                if Math.abs(n) > 1000
    #                    result = Math.round(n / 1000) + 'K'
                    result += ''
                    '$' + result.replace(/\B(?=(\d{3})+(?!\d))/g, ",");


                x.domain data.map((d) ->
                    d.name
                )
                y.domain [
                    0
                    cap
                ]

                chart.append('g').attr('class', 'x axis').attr('transform', 'translate(0,' + height + ')').call xAxis
                chart.append('g').attr('class', 'y axis').call yAxis
                chart.append("line")
                    .attr('class', 'max-value-line')
                    .attr("stroke", "#000")
                    .attr("x1", 0)
                    .attr("x2", 0)
                    .attr("y1", y gapLine)
                    .attr("y2", y gapLine)
                    .transition().duration(duration)
                    .attr("x2", width)
                bar = chart.selectAll('.bar')
                    .data(data).enter()
                    .append('g')
                        .style('fill', (d) ->
                            d.color
                        )
                        .attr('class', 'bar')
                        .attr('transform', ->
                            'translate(' + x('Revenue') + ', 0)'
                        )
                bar.transition().delay(delay).duration(duration)
                    .attr('transform', (d) ->
                        'translate(' + x(d.name) + ',0)'
                    )
                bar.append('rect').attr('y', (d) ->
                    y Math.max(d.start, d.end)
                ).attr('height', (d) ->
                    Math.abs y(d.start) - y(d.end)
                ).attr 'width', x.rangeBand()
                bar.append('text')
                    .attr('x', x.rangeBand() / 2)
                    .attr 'y', (d) ->
                        y(d.end) - 16
                    .attr 'dy', (d) ->
                        (if d.class == 'negative' then '-' else '') + '.75em'
                    .text (d) ->
                        dollarFormatter d.end - (d.start)
                    .transition().delay(delay).duration(duration)
                    .style('opacity', 1)

                bar.filter (d) ->
                    d.class != 'total'
                .append('line')
                    .attr('class', 'connector')
                    .attr('x1', x.rangeBand() + 5)
                    .attr 'y1', (d) ->
                        y d.end
                    .attr('x2', x.rangeBand() / (1 - padding) - 5)
                    .attr 'y2', (d) ->
                        y d.end
                    .transition().delay(delay).duration(duration)
                    .style('opacity', 1)

    ]
