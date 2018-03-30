@app.controller 'KPIAnalyticsController',
    ['$scope', '$document', 'KPIDashboard', 'Team', 'Product', 'Field', 'Seller','$filter'
        ($scope, $document, KPIDashboard, Team, Product, Field, Seller, $filter) ->

            #create chart===========================================================
            $scope.chartHeight = 500
            $scope.chartWidth = 1070
            $scope.chartMargin = 30
            $scope.chartOffsetX = 100
            $scope.teamFilters = []
            $scope.time_period = 'month'
            $scope.teamId = ''
            $scope.selectedTeam = {
                id:'all',
                name:'All'
            }
            $scope.datePicker = {
                startDate: null
                endDate: null
            }
            $scope.isDateSet = false
            $scope.date_criteria_filter = 'closed_date'

            datePickerInput = $document.find('#kpi-date-picker')

            $scope.datePickerApply = () ->
                if ($scope.datePicker.startDate && $scope.datePicker.endDate)
                    datePickerInput.html($scope.datePicker.startDate.format('MMM D, YY') + ' - ' + $scope.datePicker.endDate.format('MMM D, YY'))
                    $scope.isDateSet = true

            $scope.datePickerCancel = (s, r) ->
                datePickerInput.html('Time period')
                $scope.isDateSet = false

            $scope.datePickerDefault = ->
                $scope.datePicker.startDate = moment()
                    .subtract(6, 'months')
                    .date(1)
                $scope.datePicker.endDate = moment()
                    .subtract(1, 'months')
                    .endOf('month')
                datePickerInput.html($scope.datePicker.startDate.format('MMM D, YY') + ' - ' + $scope.datePicker.endDate.format('MMM D, YY'))
                $scope.isDateSet = true

            $scope.datePickerDefault()

            $scope.resetFilters = () ->
                $scope.productFilter = null
                $scope.typeFilter = null
                $scope.sourceFilter = null
                $scope.teamId = null
                $scope.selectedTeam = {
                    id:'all',
                    name:'All'
                }
                $scope.sellerFilter = null
                $scope.datePickerDefault()
                $scope.date_criteria_filter = 'closed_date'
                $scope.time_period = 'month'

            $scope.applyFilter = ->
                getData()

            resetFilters = () ->
                $scope.sellerFilters = []
                $scope.timeFilters = []
                $scope.productFilters = []
                $scope.winRateData = []

            resetTables = () ->
                $scope.winRateData = []
                $scope.dealSizeData = []

            getRandomColor = ->
                letters = '0123456789ABCDEF'
                color = '#'
                i = 0
                while i < 6
                    color += letters[Math.floor(Math.random() * 16)]
                    i++
                color

            createColorsArr = (length) ->
                $scope.colors = ['#3498DB', 'blue', 'orange', 'green', 'grey', 'yellow', 'red', 'aqua', 'purple', 'black', 'brown']
                if(length>12)
                    i = 0
                    whileLen = length-12
                    while i <= whileLen
                        $scope.colors.push(getRandomColor())
                        i++

            #init query
            $scope.isTeamsNamesInWinRateTable = true

            Product.all({active: true}).then (products) ->
                $scope.productsList = products
                $scope.productsList.unshift({name:'All', id:'all'})

            Field.defaults({}, 'Deal').then (fields) ->
                client_types = Field.findDealTypes(fields)
                $scope.typesList = []
                $scope.typesList.push({name:'All', id:'all'})
                client_types.options.forEach (option) ->
                    $scope.typesList.push(option)

                sources = Field.findSources(fields)
                $scope.sources = []
                $scope.sources.push({name:'All', id:'all'})
                sources.options.forEach (option) ->
                    $scope.sources.push(option)

            Seller.query({id: 'all'}).$promise.then (sellers) ->
                $scope.sellers = sellers
                $scope.sellers.unshift({first_name:'All', id:'all'})

            Team.all(all_teams: true).then (teams) ->
                $scope.teams = teams
                $scope.teams.unshift({
                    id:'all',
                    name:'All'
                })

            getData = () ->
                query = {
                    time_period: $scope.time_period,
                }

                if($scope.productFilter)
                    query.product_id = $scope.productFilter.id

                if($scope.typeFilter)
                    query.type = $scope.typeFilter.id

                if($scope.sourceFilter)
                    query.source = $scope.sourceFilter.id

                if($scope.teamId)
                    query.team = $scope.teamId
                    $scope.isTeamsNamesInWinRateTable = false

                if($scope.sellerFilter)
                    query.seller = $scope.sellerFilter.id
                    $scope.isTeamsNamesInWinRateTable = false

                if($scope.teamId == 'all' && ( $scope.sellerFilter == null || ($scope.sellerFilter || {}).id == 'all' ))
                    $scope.isTeamsNamesInWinRateTable = true

                if($scope.datePicker.startDate && $scope.datePicker.endDate && $scope.isDateSet)
                    query.start_date = $filter('date')($scope.datePicker.startDate._d, 'dd-MM-yyyy')
                    query.end_date = $filter('date')($scope.datePicker.endDate._d, 'dd-MM-yyyy')

                if($scope.date_criteria_filter)
                    query.date_criteria = $scope.date_criteria_filter

                KPIDashboard.get(query).$promise.then ((data) ->
                    createColorsArr(data.win_rates.length)
                    createChart(data)
                    createDSChart(data)
                    createCTChart(data)
                    initTablesData(data)
                    $scope.timeFilters = data.time_periods
                ), (err) ->
                    if err
                        console.log(err)

            #team watcher
            $scope.$watch 'selectedTeam', () ->
                $scope.teamId = $scope.selectedTeam.id
                $scope.sellerFilter = null
                Seller.query({id: $scope.teamId}).$promise.then (sellers) ->
                    $scope.sellers = sellers
                    $scope.sellers.unshift({first_name:'All', id: 'all'})

#Filters and Tables====================================================================
            initTablesData = (data)->
                resetFilters()
                resetTables()
                $scope.winRateTimePeriods = data.time_periods
                #win rates table
                $scope.winRateData = data.win_rates

                #dealSize table
                $scope.dealSizeData = data.average_deal_sizes

                #CycleTime table
                $scope.cycleTimeData = data.cycle_times

            $scope.filterByPeriod =(period) ->
                $scope.time_period = period

            $scope.filterBySeller =(seller) ->
                $scope.sellerFilter = seller

            $scope.filterByProduct =(product) ->
                $scope.productFilter = product

            $scope.filterByType =(type) ->
                $scope.typeFilter = type

            $scope.filterBySource =(source) ->
                $scope.sourceFilter = source

            $scope.filterByDateCriteria = (source) ->
                $scope.date_criteria_filter = source

#=====END Filters====================================================================
#=======================WIN RATE=======================================================
            getCorrectFactor = (i) ->
                i % 6

            createLegend = (data, selector) ->
                #calculating graph container height depends on data
                d3.select(selector)
                    .attr('style', 'height: ' + (520 + Math.ceil((data.length) / 6) * 20) + 'px')

                legendTable = d3.select(selector+" svg").append("g")
                    .attr("transform", "translate(70, "+($scope.chartHeight+15)+")")
                    .attr("class", "legendTable");
                legend = legendTable.selectAll(selector+' .legend')
                    .data(data).enter()
                    .append('g')
                    .attr('class', 'legend')
                    .attr('transform', (d, i) ->
                        return 'translate(' + getCorrectFactor(i) * 100 + ', 0)'
                    )

                legend.append('rect')
                    .attr('x', (d, i) ->
                        return getCorrectFactor(i) * 70
                    )
                    .attr('y', (d, i) ->
                        Math.floor(i / 6) * 20
                    )
                    .attr('width', 13)
                    .attr('height', 13)
                    .attr("rx", 4)
                    .attr("ry", 4)
                    .style 'fill', (d) ->
                        d.color

                legend.append('text')
                    .attr('x', (d, i) ->
                        return getCorrectFactor(i) * 70 + 20
                    )
                    .attr('y', (d, i) ->
                        Math.floor(i / 6) * 20 + 10
                    )
                    .attr('height', 30)
                    .attr('width', 150)
                    .text (d) ->
                        d.label

            createItemChart = (data, colorStroke, label, dashed) ->
                # make lines function
                line = d3.svg.line().interpolate('monotone').x((d) ->
                    $scope.scaleX(d.x) + $scope.chartMargin
                ).y((d) ->
                    $scope.scaleY(d.y) + $scope.chartMargin
                )
                g = $scope.svg.append('g')
                if dashed
                    g.append('path')
                        .attr('d', line(data))
                        .style('stroke', colorStroke)
                        .style("stroke-dasharray", "10 8")
                        .style("stroke-width", "3")
                else
                    g.append('path')
                        .attr('d', line(data))
                        .style('stroke', colorStroke)
                        .style('stroke-width', 2)

                #Define the div for the tooltip
                div = d3.select(".win-rate").append("div")
                    .attr("class", "tooltip")
                    .style("opacity", 0);

                # dots
                $scope.svg.selectAll('.dot' + label)
                    .data(data)
                    .enter()
                    .append('circle')
                    .style('stroke', colorStroke)
                    .style('fill', colorStroke)
                    .style('cursor', 'pointer')
                    .attr('class', 'dot' + label)
                    .attr('r', (d) ->
                        d.r
                    ).attr('cx', (d) ->
                        $scope.scaleX(d.x) + $scope.chartMargin
                    ).attr('cy', (d) ->
                        $scope.scaleY(d.y) + $scope.chartMargin
                    ).on('mouseover', (d) ->
                            div.transition().duration(200).style 'opacity', 1
                            div.html('<p>'+ d.seller + '</p><p><span>' + d.win_rate + '%</span><span>' +d.wins+ '</span><span>' +d.loses+'</span></p><p><span>Win Rate</span><span>Wins</span><span>Losses</span></p>')
                            .style('left', $scope.scaleX(d.x) + $scope.chartMargin - 115 + 'px')
                            .style('top', $scope.scaleY(d.y) + $scope.chartMargin + 18 + 'px')
                    ).on 'mouseout', (d) ->
                        div.transition().duration(500).style 'opacity', 0

            transformData = (data) ->
                dataCopyWinRates = angular.copy(data.win_rates)
                #move Average up
                averageData = dataCopyWinRates.pop()
                dataCopyWinRates.unshift(averageData)

                optimizedData = []
                i = 0
                len = dataCopyWinRates.length
                while i < len
                    item = {
                        data: [],
                        color: $scope.colors[i],
                        label: dataCopyWinRates[i][0],
                    }
                    _.each dataCopyWinRates[i], (dataItem, index) ->
                        if (dataItem.win_rate != undefined && dataItem.total_deals != undefined)
                            dot = {
                                x:index,
                                y: dataItem.win_rate,
                                win_rate:dataItem.win_rate,
                                wins:dataItem.won,
                                loses:dataItem.lost
                                seller:dataCopyWinRates[i][0]
                            }
                            if(dataItem.total_deals < 10)
                                dot.r = 3
                            if(dataItem.total_deals >= 10 && dataItem.total_deals <= 20)
                                dot.r = 5
                            if(dataItem.total_deals > 20)
                                dot.r = 10
                            item.data.push(dot)
                    optimizedData.push(item)
                    i++
                optimizedData

            createAxis = (data, time_periods) ->
                $scope.svg = d3.select(".win-rate").append("svg")
                    .attr("class", "axis")
                    .attr("width", $scope.chartWidth)
                    .attr("height", $scope.chartHeight);

                #length X = width svg container - margin left and right
                xAxisLength = $scope.chartWidth - 2 * $scope.chartMargin;
                #length Y = height svg container -  margin top and bottom
                yAxisLength = $scope.chartHeight- 2 * $scope.chartMargin;
                #find max value for Y
                maxValue = 100;
                #find min value for Y
                minValue = 0;

                #interpolate function for X
                $scope.scaleX = d3.scale.linear()
                    .domain([1, time_periods.length])
                    .range([$scope.chartOffsetX, xAxisLength]);

                #interpolate function for Y
                $scope.scaleY = d3.scale.linear()
                    .domain([maxValue, minValue])
                    .range([0, yAxisLength])

                #make X
                xAxis = d3.svg.axis()
                    .scale($scope.scaleX)
                    .orient('bottom')
                    .tickFormat((d, i) ->
                        time_periods[i]
                    )
                    .tickPadding(10)
                    .ticks(time_periods.length - 1)

                #make Y
                yAxis = d3.svg.axis()
                    .scale($scope.scaleY)
                    .orient('left')
                    .tickValues([20, 40, 60, 80, 100])
                    .tickFormat((d) -> d + "%");

                #paint Х
                $scope.svg.append('g')
                    .attr('class', 'x-axis')
                    .attr('style', 'opacity:0.6')
                    .attr('transform', 'translate(' + $scope.chartMargin + ',' + ($scope.chartHeight- $scope.chartMargin) + ')')
                    .call xAxis

                #paint Y
                $scope.svg.append('g').attr('class', 'y-axis')
                .attr('style', 'opacity:0.6')
                .attr('transform', 'translate(' + $scope.chartMargin + ',' + $scope.chartMargin + ')')
                .call yAxis

                #extra X
                $scope.svg.append('g').attr('class', 'x-extra-axis')
                .attr('transform', 'translate(' + $scope.chartMargin + ',' + ($scope.chartHeight- $scope.chartMargin) + ')')
                .call (d3.svg.axis().scale(
                    d3.scale.linear()
                    .domain([1])
                    .range([0, $scope.chartOffsetX])
                ).orient('bottom'))

                #paint gorizontal lines
                d3.selectAll('.win-rate g.y-axis g.tick')
                    .append('line').classed('grid-line', true)
                    .attr('x1', 0)
                    .attr('y1', 0)
                    .attr('x2', xAxisLength)
                    .attr('y2', 0)

                #add legend
                createLegend(data, '.win-rate')

            createChart = (data)->
                d3.select(".win-rate svg").remove();
                optimizeData = transformData(data)
                createAxis(optimizeData, data.time_periods)
                average = optimizeData.shift()
                createItemChart(average.data, average.color, average.color.replace(/#/, ''), true);
                _.each optimizeData, (chart) ->
                    createItemChart(chart.data, chart.color, chart.color.replace(/#/, ''));

#=======================END WIN RATE=======================================================
#=======================DEAl SIZE=======================================================
            createDSItemChart = (data, colorStroke, label, dashed) ->
            # make lines function
                line = d3.svg.line().interpolate('monotone').x((d) ->
                    $scope.scaleDSX(d.x) + $scope.chartMargin
                ).y((d) ->
                    $scope.scaleDSY(d.y) + $scope.chartMargin
                )
                g = $scope.svgDS.append('g')
                if dashed
                    g.append('path')
                        .attr('d', line(data))
                        .style('stroke', colorStroke)
                        .style("stroke-dasharray", "10 8")
                        .style('stroke-width', 3)
                else
                    g.append('path')
                        .attr('d', line(data))
                        .style('stroke', colorStroke)
                        .style('stroke-width', 2)

                #Define the div for the tooltip
                div = d3.select(".deal-size").append("div")
                .attr("class", "tooltip-small")
                .style("opacity", 0);

                # dots
                $scope.svgDS.selectAll('.dot' + label)
                .data(data)
                .enter()
                .append('circle')
                .style('stroke', colorStroke)
                .style('fill', colorStroke)
                .style('cursor', 'pointer')
                .attr('class', 'dot' + label)
                .attr('r', (d) ->
                    d.r
                ).attr('cx', (d) ->
                    $scope.scaleDSX(d.x) + $scope.chartMargin
                ).attr('cy', (d) ->
                    $scope.scaleDSY(d.y) + $scope.chartMargin
                ).on('mouseover', (d) ->
                    if(d.win_rate)
                        win_rate = '$' + (d.win_rate+'').replace(/(\d)(?=(\d\d\d)+([^\d]|$))/g, "$&,") + 'k'
                    else
                        win_rate = 0

                    div.transition().duration(200).style 'opacity', 1
                    div.html('<p>'+ d.seller + '</p><p><span>' + win_rate + '</span><span>' +d.wins+ '</span></p><p><span>Deal Size</span><span>Wins</span></p>')
                    .style('left', $scope.scaleDSX(d.x) + $scope.chartMargin - 105 + 'px')
                    .style('top', $scope.scaleDSY(d.y) + $scope.chartMargin + 18 + 'px')
                ).on 'mouseout', (d) ->
                    div.transition().duration(500).style 'opacity', 0

            transformDSData = (data) ->
                dataCopyDealSize = angular.copy(data.average_deal_sizes)
                #move Average up
                averageData = dataCopyDealSize.pop()
                dataCopyDealSize.unshift(averageData)

                optimizedData = []
                i = 0
                len = dataCopyDealSize.length
                while i < len
                    item = {
                        data: [],
                        color: $scope.colors[i],
                        label: dataCopyDealSize[i][0],
                    }
                    _.each dataCopyDealSize[i], (dataItem, index) ->
                        if (dataItem.average_deal_size != undefined && dataItem.total_deals != undefined)
                            dot = {
                                x:index,
                                y: dataItem.average_deal_size,
                                win_rate:dataItem.average_deal_size,
                                wins:dataItem.won || 0,
                                seller:dataCopyDealSize[i][0]
                            }
                            if(dataItem.won < 10)
                                dot.r = 3
                            else if(dataItem.won < 20)
                                dot.r = 5
                            else if(dataItem.won >= 20)
                                dot.r = 10
                            item.data.push(dot)
                    optimizedData.push(item)
                    i++
                optimizedData

            createDSAxis = (data, time_periods) ->
                $scope.svgDS = d3.select(".deal-size").append("svg")
                .attr("class", "axis")
                .attr("width", $scope.chartWidth)
                .attr("height", $scope.chartHeight);

                #length X = width svg container - margin left and right
                xAxisLength = $scope.chartWidth - 2 * $scope.chartMargin;
                #length Y = height svg container -  margin top and bottom
                yAxisLength = $scope.chartHeight- 2 * $scope.chartMargin;

                #find max value for Y
                maxValue = 0;
                _.each data, (dataItem) ->
                    _.each dataItem.data, (dataDot) ->
                        if(dataDot.y && maxValue < dataDot.y)
                            maxValue = dataDot.y

                ticksArr = []
                if maxValue > 0
                    step = (() ->
                        if maxValue <= 10 then return 1
                        Math.ceil((maxValue / 10) / 10) * 10
                    )()
                    for i in [0..maxValue + step] by step
                        ticksArr.push(i)
                        if i >= maxValue
                            maxValue = i
                            break
                else
                    ticksArr = [0]

                #find min value for Y
                minValue = 0;

                #interpolate function for X
                $scope.scaleDSX = d3.scale.linear()
                .domain([1, time_periods.length])
                .range([$scope.chartOffsetX, xAxisLength]);

                #interpolate function for Y
                $scope.scaleDSY = d3.scale.linear()
                .domain([maxValue || 1, minValue])
                .range([0, yAxisLength])

                # make X
                xAxis = d3.svg.axis()
                .scale($scope.scaleDSX)
                .orient('bottom')
                .tickFormat((d, i) ->
                    time_periods[i]
                )
                .tickPadding(10)
                .ticks(time_periods.length - 1)

                #make Y
                yAxis = d3.svg.axis()
                .scale($scope.scaleDSY)
                .orient("left")
                .tickFormat((d) ->
                    if(d == 0)
                        0
                    else
                        '$'+(d+'').replace(/(\d)(?=(\d\d\d)+([^\d]|$))/g, "$&,")+'k'
                )
                .tickValues(ticksArr)


                #paint Х
                $scope.svgDS.append('g')
                .attr('class', 'x-axis')
                .attr('style', 'opacity:0.6')
                .attr('transform', 'translate(' + $scope.chartMargin + ',' + ($scope.chartHeight- $scope.chartMargin) + ')')
                .call xAxis

                #paint Y
                $scope.svgDS.append('g').attr('class', 'y-axis')
                .attr('style', 'opacity:0.6')
                .attr('transform', 'translate(' + $scope.chartMargin + ',' + $scope.chartMargin + ')')
                .call yAxis

                #extra X
                $scope.svgDS.append('g').attr('class', 'x-extra-axis')
                .attr('transform', 'translate(' + $scope.chartMargin + ',' + ($scope.chartHeight- $scope.chartMargin) + ')')
                .call (d3.svg.axis().scale(
                    d3.scale.linear()
                    .domain([1])
                    .range([0, $scope.chartOffsetX])
                ).orient('bottom'))

                #paint gorizontal lines
                d3.selectAll('.deal-size g.y-axis g.tick')
                .append('line').classed('grid-line', true)
                .attr('x1', 0)
                .attr('y1', 0)
                .attr('x2', xAxisLength)
                .attr('y2', 0)

                #add legend
                createLegend(data, '.deal-size')

            createDSChart = (data)->
                d3.select(".deal-size svg").remove();
                optimizeData = transformDSData(data)
                createDSAxis(optimizeData, data.time_periods)
                average = optimizeData.shift()
                createDSItemChart(average.data, average.color, average.color.replace(/#/, ''), true);
                _.each optimizeData, (chart) ->
                    createDSItemChart(chart.data, chart.color, chart.color.replace(/#/, ''));


#=======================END DEAL SIZE=======================================================
#=======================Cycle Time=======================================================
            createCTItemChart = (data, colorStroke, label, dashed) ->
# make lines function
                line = d3.svg.line().interpolate('monotone').x((d) ->
                    $scope.scaleCTX(d.x) + $scope.chartMargin
                ).y((d) ->
                    $scope.scaleCTY(d.y) + $scope.chartMargin
                )
                g = $scope.svgCT.append('g')
                if dashed
                    g.append('path')
                        .attr('d', line(data))
                        .style('stroke', colorStroke)
                        .style("stroke-dasharray", "10 8")
                        .style('stroke-width', 3)
                else
                    g.append('path')
                        .attr('d', line(data))
                        .style('stroke', colorStroke)
                        .style('stroke-width', 2)

                #Define the div for the tooltip
                div = d3.select(".cycle-time").append("div")
                .attr("class", "tooltip-small")
                .style("opacity", 0);

                # dots
                $scope.svgCT.selectAll('.dot' + label)
                .data(data)
                .enter()
                .append('circle')
                .style('stroke', colorStroke)
                .style('fill', colorStroke)
                .style('cursor', 'pointer')
                .attr('class', 'dot' + label)
                .attr('r', (d) ->
                    d.r
                ).attr('cx', (d) ->
                    $scope.scaleCTX(d.x) + $scope.chartMargin
                ).attr('cy', (d) ->
                    $scope.scaleCTY(d.y) + $scope.chartMargin
                ).on('mouseover', (d) ->
                    div.transition().duration(200).style 'opacity', 1
                    div.html('<p>'+ d.seller + '</p><p><span>' + d.win_rate + '</span><span>' +d.wins+ '</span></p><p><span>Cycle Time</span><span>Wins</span></p>')
                    .style('left', $scope.scaleCTX(d.x) + $scope.chartMargin - 105 + 'px')
                    .style('top', $scope.scaleCTY(d.y) + $scope.chartMargin + 18 + 'px')
                ).on 'mouseout', (d) ->
                    div.transition().duration(500).style 'opacity', 0

            transformCTData = (data) ->
                dataCopyCycleTimeSize = angular.copy(data.cycle_times)
                #move Average up
                averageData = dataCopyCycleTimeSize.pop()
                dataCopyCycleTimeSize.unshift(averageData)

                optimizedData = []
                i = 0
                len = dataCopyCycleTimeSize.length
                while i < len
                    item = {
                        data: [],
                        color: $scope.colors[i],
                        label: dataCopyCycleTimeSize[i][0],
                    }
                    _.each dataCopyCycleTimeSize[i], (dataItem, index) ->
                        if (dataItem.cycle_time != undefined && dataItem.total_deals != undefined)
                            dot = {
                                x:index,
                                y: dataItem.cycle_time,
                                win_rate:dataItem.cycle_time,
                                wins:dataItem.won || 0,
                                seller:dataCopyCycleTimeSize[i][0]
                            }
                            if(dataItem.won < 10)
                                dot.r = 3
                            else if(dataItem.won < 20)
                                dot.r = 5
                            else if(dataItem.won >= 20)
                                dot.r = 10
                            item.data.push(dot)
                    optimizedData.push(item)
                    i++
                optimizedData

            createCTAxis = (data, time_periods) ->
                $scope.svgCT = d3.select(".cycle-time").append("svg")
                .attr("class", "axis")
                .attr("width", $scope.chartWidth)
                .attr("height", $scope.chartHeight);

                #length X = width svg container - margin left and right
                xAxisLength = $scope.chartWidth - 2 * $scope.chartMargin;
                #length Y = height svg container -  margin top and bottom
                yAxisLength = $scope.chartHeight- 2 * $scope.chartMargin;

                #find max value for Y
                maxValue =  0;
                _.each data, (dataItem) ->
                    _.each dataItem.data, (dataDot) ->
                        if(dataDot.y && maxValue < dataDot.y)
                            maxValue = dataDot.y
                ticksArr = []
                if maxValue > 0
                    step = (() ->
                        if maxValue <= 10 then return 1
                        Math.ceil((maxValue / 10) / 10) * 10
                    )()
                    for i in [0..maxValue + step] by step
                        ticksArr.push(i)
                        if i >= maxValue
                            maxValue = i
                            break
                else
                    ticksArr = [0]
                #find min value for Y
                minValue = 0;

                #interpolate function for Y
                $scope.scaleCTY = d3.scale.linear()
                .domain([maxValue || 10, minValue])
                .range([0, yAxisLength])

                #interpolate function for X
                $scope.scaleCTX = d3.scale.linear()
                    .domain([1, time_periods.length])
                    .range([$scope.chartOffsetX, xAxisLength])

                # make X
                xAxis = d3.svg.axis()
                    .scale($scope.scaleCTX)
                    .orient('bottom')
                    .tickFormat((d, i) ->
                        time_periods[i]
                    )
                    .tickPadding(10)
                    .ticks(time_periods.length - 1)

                #make Y
                yAxis = d3.svg.axis()
                    .scale($scope.scaleCTY)
                    .orient("left")
                    .tickFormat((d) ->
                        if d > 0 then return d + ' Days'
                        return d
                    )
                    .tickValues(ticksArr)

                #paint Х
                $scope.svgCT.append('g')
                .attr('class', 'x-axis')
                .attr('style', 'opacity:0.6')
                .attr('transform', 'translate(' + $scope.chartMargin + ',' + ($scope.chartHeight- $scope.chartMargin) + ')')
                .call xAxis

                #paint Y
                $scope.svgCT.append('g').attr('class', 'y-axis')
                .attr('style', 'opacity:0.6')
                .attr('transform', 'translate(' + $scope.chartMargin + ',' + $scope.chartMargin + ')')
                .call yAxis

                #extra X
                $scope.svgCT.append('g').attr('class', 'x-extra-axis')
                .attr('transform', 'translate(' + $scope.chartMargin + ',' + ($scope.chartHeight- $scope.chartMargin) + ')')
                .call (d3.svg.axis().scale(
                    d3.scale.linear()
                    .domain([1])
                    .range([0, $scope.chartOffsetX])
                ).orient('bottom'))

                #paint gorizontal lines
                d3.selectAll('.cycle-time g.y-axis g.tick')
                .append('line').classed('grid-line', true)
                .attr('x1', 0)
                .attr('y1', 0)
                .attr('x2', xAxisLength)
                .attr('y2', 0)

                #add legend
                createLegend(data, '.cycle-time')

            createCTChart = (data)->
                d3.select(".cycle-time svg").remove();
                optimizeData = transformCTData(data)
                createCTAxis(optimizeData, data.time_periods)
                average = optimizeData.shift()
                createCTItemChart(average.data, average.color, average.color.replace(/#/, ''), true);
                _.each optimizeData, (chart) ->
                    createCTItemChart(chart.data, chart.color, chart.color.replace(/#/, ''));


#=======================END Cycle Time=======================================================
    ]
