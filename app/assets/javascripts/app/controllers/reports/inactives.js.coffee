@app.controller 'InactivesController',
    ['$scope', '$document', 'InactivesService', 'Product', 'Field'
        ($scope, $document, IN, Product, Field) ->
            colors = ['#3498DB', '#8CC135']
            $scope.inactive =
                data: null
                chartId: '#inactive-chart'
                lookbackWindow: [
                    {name: '1 Qtr', value: 1}
                    {name: '2 Qtrs', value: 2}
                    {name: '3 Qtrs', value: 3}
                    {name: '4 Qtrs', value: 4}
                    {name: '5 Qtrs', value: 5}
                    {name: '6 Qtrs', value: 6}
                    {name: '7 Qtrs', value: 7}
                    {name: '8 Qtrs', value: 8}
                ]
                filter: {}
                selected: {}
                setFilter: (type, item) ->
                    if !item then return
                    this.selected[type] = item
                    switch type
                        when 'qtrs' then this.filter.qtrs = item.value
                        when 'product' then this.filter.product_id = item.id
                        when 'category'
                            this.filter.category_id = item.id
                            this.filter.subcategory_id = undefined
                            if item.suboptions
                                this.selected.subcategory = undefined
                                this.subcategories = angular.copy item.suboptions
                                this.subcategories.unshift({name: 'All', id: null})
                            else
                                this.subcategories = this.allSubcategories
                        when 'subcategory' then this.filter.subcategory_id = item.id
                    this.applyFilter()

                resetFilter: ->
                    this.selected = {'qtrs': {name: '2 Qtrs', value: 2}}
                    this.filter = {'qtrs': 2}
                    this.subcategories = this.allSubcategories
                    this.applyFilter()

                applyFilter: ->
                    IN.inactive(this.filter).$promise.then ((data) ->
                        $scope.inactive.data = angular.copy(data)
                        drawChart(data, $scope.inactive.chartId, true)
                    ), (err) ->
                        if err then console.log(err)
            #default filters
            $scope.inactive.setFilter('qtrs', $scope.inactive.lookbackWindow[1])

            currentQuarter = moment().quarter()
            $scope.seasonalInactive =
                data: null
                chartId: '#seasonal-chart'
                selectedType: 'quarters'
                default: {}
                comparisonTypes: [
                    {name: 'Quarters', value: 'quarter'}
                    {name: 'Months', value: 'month'}
                ]
                filter: {}
                selected: {}
                setFilter: (type, item) ->
                    if !item then return
                    this.selected[type] = item
                    switch type
                        when 'comparisonType'
                            this.selectedType = item.name.toLowerCase()
                            this.filter['time_period_type'] = item.value
                            if this.comparisonNames
                                return this.setFilter('comparisonNumber', this.comparisonNames[this.selectedType][0])
                        when 'comparisonNumber' then this.filter['time_period_number'] = item.value
                        when 'category'
                            this.filter.category_id = item.id
                            this.filter.subcategory_id = undefined
                            if item.suboptions
                                this.selected.subcategory = undefined
                                this.subcategories = angular.copy item.suboptions
                                this.subcategories.unshift({name: 'All', id: null})
                            else
                                this.subcategories = this.allSubcategories
                        when 'subcategory' then this.filter.subcategory_id = item.id
                    this.applyFilter()

                resetFilter: ->
                    this.selectedType = 'quarters'
                    this.selected = angular.copy this.default.selected
                    this.filter = angular.copy this.default.filter
                    this.subcategories = this.allSubcategories
                    this.applyFilter()

                applyFilter: ->
                    IN.seasonalInactive(this.filter).$promise.then ((data) ->
                        _this = $scope.seasonalInactive
                        _this.data = angular.copy(data['seasonal_inactives'])
                        if !_this.selected.comparisonNumber && data['season_names']
                            data['season_names'].quarters.reverse()
                            data['season_names'].months.reverse()
                            _this.comparisonNames = data['season_names']
                            _this.selected.comparisonNumber = _this.comparisonNames[_this.selectedType][0]
                            _this.filter['time_period_number'] = _this.selected.comparisonNumber.value
                            _this.default =
                                selected: angular.copy _this.selected
                                filter: angular.copy _this.filter
                        drawChart(data['seasonal_inactives'], _this.chartId, true)
                    ), (err) ->
                        if err then console.log(err)

            #default filters
            $scope.seasonalInactive.setFilter('comparisonType', $scope.seasonalInactive.comparisonTypes[0])

            Field.defaults({}, 'Client').then (clients) ->
                categories = [{name: 'All', id: null}]
                subcategories = [{name: 'All', id: null}]
                for client in clients
                    if client.name is 'Category'
                        for category in client.options
                            categories.push category
                            for subcategory in category.suboptions
                                subcategories.push subcategory

                $scope.inactive.categories = categories
                $scope.seasonalInactive.categories = categories
                $scope.inactive.subcategories = $scope.inactive.allSubcategories = subcategories
                $scope.seasonalInactive.subcategories = $scope.seasonalInactive.allSubcategories = subcategories

            drawChart = (data, chartId, isUpdating) ->
                if !data || !data.length then return
                data.reverse()

                width = 940
                height = data.length * 90
                margin =
                    top: 30
                    right: 40
                    bottom: 70
                    left: 150

                x = d3.scale.linear().range([
                    0
                    width
                ], .05)

                y = d3.scale.ordinal().rangeRoundBands([
                    height
                    0
                ])

                maxValue = d3.max data, (d) ->
                    Math.max(d.average_quarterly_spend, d.open_pipeline)

                ticksArr = []
                if maxValue > 0
                    step = (() ->
                        if maxValue <= 10000 then return 1000
                        Math.ceil((maxValue / 10000) / 5) * 10000
                    )()
                    for i in [0..maxValue + step] by step
                        ticksArr.push(i)
                        if i >= maxValue
                            maxValue = i
                            break
                else
                    ticksArr = [0]

                xAxis = d3.svg.axis()
                    .scale(x)
                    .orient('bottom')
                    .tickValues(ticksArr)
                    .tickFormat (v) ->
                        if v > 0 then return '$' + v.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") else v

                yAxis = d3.svg.axis()
                    .scale(y)
                    .orient('left')

                svg = d3.select(chartId)
                if isUpdating then svg.html('')

                svg = svg
                    .attr('width', width + margin.left + margin.right)
                    .attr('height', height + margin.top + margin.bottom)
                    .append('g')
                    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

                x.domain [0, maxValue]

                y.domain data.map((d) ->
                    d.client_name
                )

                svg.append('g')
                    .attr('class', 'x axis')
                    .attr('transform', 'translate(0,' + height + ')')
                    .call(xAxis)
                    .selectAll('text')
                    .style('text-anchor', 'middle')
                    .attr('y', 16)
                svg.append('g')
                    .attr('class', 'y axis')
                    .call(yAxis)
                    .append('text')
                    .attr('transform', 'rotate(-90)')
                    .attr('y', 6)
                    .attr('dy', '.71em')
                    .style('text-anchor', 'end')
                barWidth = 25
                barsWithData = svg.selectAll('bar').data(data).enter()
                barsWithData
                    .append('rect')
                    .style('fill', colors[0])
                    .attr('height', barWidth)
                    .attr('x', 1)
                    .attr 'y', (d) ->
                        (y(d.client_name) + (y.rangeBand() - barWidth) / 2) - (barWidth / 2 + 4)
                    .attr 'width', 0
                    .transition()
                    .duration 1000
                    .delay 300
                    .attr 'width', (d) ->
                        x(d.average_quarterly_spend)
                barsWithData
                    .append('rect')
                    .style('fill', colors[1])
                    .attr('height', barWidth)
                    .attr('x', 1)
                    .attr 'y', (d) ->
                        (y(d.client_name) + (y.rangeBand() - barWidth) / 2) + (barWidth / 2 + 4)
                    .attr 'width', 0
                    .transition()
                    .duration 1000
                    .delay 300
                    .attr 'width', (d) ->
                        x(d.open_pipeline)

                legendData = [
                    {color: colors[0], label: 'Ave Spend per Qtr'}
                    {color: colors[1], label: 'Open Pipeline'}
                ]

                #add legend
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
                    .attr('x', (d, i) -> (i % 6) * 70)
                    .attr('y', (d, i) -> Math.floor(i / 6) * 20)
                    .attr('width', 13)
                    .attr('height', 13)
                    .attr("rx", 4)
                    .attr("ry", 4)
                    .style 'fill', (d) -> d.color
                legend.append('text')
                    .attr('x', (d, i) -> (i % 6) * 70 + 20)
                    .attr('y', (d, i) -> Math.floor(i / 6) * 20 + 10)
                    .attr('height', 30)
                    .attr('width', 150)
                    .text (d) -> d.label

    ]