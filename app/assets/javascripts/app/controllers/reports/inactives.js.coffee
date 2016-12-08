@app.controller 'InactivesController',
    ['$scope', '$document', 'InactivesService', 'Product', 'Field'
        ($scope, $document, IN, Product, Field) ->
            colors = ['#3498DB', '#8CC135']

            $scope.lookbackWindow = [
                {name: '1 Qtr', value: 1}
                {name: '2 Qtrs', value: 2}
                {name: '3 Qtrs', value: 3}
                {name: '4 Qtrs', value: 4}
                {name: '5 Qtrs', value: 5}
                {name: '6 Qtrs', value: 6}
                {name: '7 Qtrs', value: 7}
                {name: '8 Qtrs', value: 8}
            ]
            $scope.filter = {'qtrs': 2}
            $scope.selected = {'qtrs': {name: '2 Qtrs', value: 2}}

            $scope.setFilter = (type, item) ->
                if !item then return
                $scope.selected[type] = item
                switch type
                    when 'qtrs' then $scope.filter.qtrs = item.value
                    when 'team' then $scope.filter.team = item.id
                    when 'seller' then $scope.filter.seller = item.id
                    when 'product' then $scope.filter.product_id = item.id
                    when 'category'
                        $scope.filter.category_id = item.id
                        $scope.filter.subcategory_id = undefined
                        if item.suboptions
                            $scope.subcategories = angular.copy item.suboptions
                            $scope.subcategories.unshift({name: 'All', id: null})
                        else
                            $scope.subcategories = $scope.allSubcategories
                    when 'subcategory' then $scope.filter.subcategory_id = item.id

                applyFilter()

            $scope.resetFilter = ->
                $scope.selected = {'qtrs': {name: '2 Qtrs', value: 2}}
                $scope.filter = {'qtrs': 2}
                $scope.subcategories = $scope.allSubcategories
                applyFilter()

            #initial query
            IN.get().$promise.then ((data) ->

                Product.all().then (products) ->
                    $scope.productsList = products
                    $scope.productsList.unshift({name: 'All', id: null})

                Field.defaults({}, 'Client').then (clients) ->
                    categories = [{name: 'All', id: null}]
                    subcategories = [{name: 'All', id: null}]
                    for client in clients
                        if client.name is 'Category'
                            for category in client.options
                                categories.push category
                                for subcategory in category.suboptions
                                    subcategories.push subcategory

                    $scope.categories = categories
                    $scope.subcategories = $scope.allSubcategories = subcategories

                $scope.inactives = angular.copy(data.inactives)
                drawChart(data.inactives)

            ), (err) ->
                if err then console.log(err)

            applyFilter = ->
                IN.get($scope.filter).$promise.then ((data) ->
                    $scope.inactives = angular.copy(data.inactives)
                    drawChart(data.inactives, true)
                ), (err) ->
                    if err then console.log(err)

            drawChart = (data, isUpdating) ->

                data.reverse()

                width = 940
                height = data.length * 90
                margin =
                    top: 30
                    right: 40
                    bottom: 70
                    left: 100

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

                svg = d3.select('#inactive-chart')
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