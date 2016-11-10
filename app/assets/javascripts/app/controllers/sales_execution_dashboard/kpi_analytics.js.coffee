@app.controller 'KPIAnalyticsController',
  ['$scope', 'KPIDashboard',
    ($scope, KPIDashboard) ->

      #create chart===========================================================
      $scope.chartHeight= 500
      $scope.chartWidth = 1070
      $scope.chartMargin= 30
      $scope.scaleX = null
      $scope.scaleY = null
      $scope.svg = null

      $scope.data = [
        {
          data: [
            {x:1, y: 42, r:5},
            {x:2, y: 50, r:5},
            {x:3, y: 10, r:5},
            {x:4, y: 50, r:5}
          ],
          color: 'blue',
          label: 'seller2',
        },
        {
          data: [
            {x:1, y: 25, r:10},
            {x:2, y: 3, r:13},
            {x:3, y: 10, r:5},
            {x:4, y: 41, r:5}
          ],
          color: 'orange',
          label: 'seller1',
        }
      ]

      KPIDashboard.get().$promise.then ((defaultData) ->
        createChart(defaultData)
      ), (err) ->
        if err
          console.log(err)

      createItemChart = (data, colorStroke, label) ->
        # make lines function
        line = d3.svg.line().interpolate('monotone').x((d) ->
          $scope.scaleX(d.x) + $scope.chartMargin
        ).y((d) ->
          $scope.scaleY(d.y) + $scope.chartMargin
        )
        g = $scope.svg.append('g')
        g.append('path')
          .attr('d', line(data))
          .style('stroke', colorStroke)
          .style('stroke-width', 2)
        # dots
        $scope.svg.selectAll('.dot ' + label)
          .data(data)
          .enter()
          .append('circle')
          .style('stroke', colorStroke)
          .style('fill', colorStroke)
          .attr('class', 'dot ' + label)
          .attr('r', (d) ->
            d.r
          ).transition().duration(2000)
          .attr('cx', (d) ->
            $scope.scaleX(d.x) + $scope.chartMargin
          ).attr 'cy', (d) ->
            $scope.scaleY(d.y) + $scope.chartMargin
        return

      transformData = (data) ->
        $scope.data

      crateAxis = (data, time_periods) ->
        $scope.svg = d3.select(".graph").append("svg")
          .attr("class", "axis")
          .attr("width", $scope.chartWidth)
          .attr("height", $scope.chartHeight);

        #length X = width svg container - margin left and right
        xAxisLength = $scope.chartWidth - 2 * $scope.chartMargin;
        #length Y = height svg container -  margin top and bottom
        yAxisLength = $scope.chartHeight- 2 * $scope.chartMargin;
        #find max value for Y
        maxValue = 80;
        #find min value for Y
        minValue = 0;

        #interpolate function for Y
        $scope.scaleY = d3.scale.linear()
          .domain([maxValue, minValue])
          .range([0, yAxisLength]);

        #interpolate function for Y
        $scope.scaleX = d3.scale.linear()
          .domain([0, 4])
          .range([0, xAxisLength]);

        # make X
        xAxis = d3.svg.axis()
          .scale($scope.scaleX)
          .orient('bottom')
          .tickFormat((d, i) ->
            time_periods[i-1] || 0
          ).ticks(4)

        #make Y
        yAxis = d3.svg.axis()
          .scale($scope.scaleY)
          .orient('left')

        #paint Х
        $scope.svg.append('g')
          .attr('class', 'x-axis')
          .attr('transform', 'translate(' + $scope.chartMargin + ',' + ($scope.chartHeight- $scope.chartMargin) + ')')
          .call xAxis

        #paint Y
        $scope.svg.append('g').attr('class', 'y-axis')
          .attr('transform', 'translate(' + $scope.chartMargin + ',' + $scope.chartMargin + ')')
          .call yAxis

        #paint gorizontal lines
        d3.selectAll('g.y-axis g.tick')
          .append('line').classed('grid-line', true)
          .attr('x1', 0)
          .attr('y1', 0)
          .attr('x2', xAxisLength)
          .attr('y2', 0)

        #add legend
        legendTable = d3.select("svg").append("g")
          .attr("transform", "translate(70, "+($scope.chartHeight+15)+")")
          .attr("class", "legendTable");
        legend = legendTable.selectAll('.legend')
          .data(data).enter()
          .append('g')
          .attr('class', 'legend')
          .attr('transform', (d, i) ->
            'translate(' + i * 100 + ', 0)'
          )

        legend.append('rect')
          .attr('x', (d, i) ->
            i * 50
          )
          .attr('y', 0)
          .attr('width', 10)
          .attr('height', 10)
          .style 'fill', (d) ->
            d.color

        legend.append('text')
          .attr('x', (d, i) ->
            i * 50 + 15
          )
          .attr('y', 10)
          .attr('height', 30)
          .attr('width', 100)
          .text (d) ->
            d.label

      createChart = (data)->
        optimizeData = transformData(data)
        time_periods=["May","June","July","August","September","October"]
        crateAxis(optimizeData, time_periods)
        _.each optimizeData, (chart) ->
          createItemChart(chart.data, chart.color, chart.label);


      #END create chart===========================================================
        $scope.teamFilters = [
          { name: 'My Team', param: '' }
          { name: 'All Team', param: 'all' }
        ]

        $scope.sellerFilters = [
          { name: 'seller1', param: 'seller1' }
          { name: 'seller2', param: 'seller2' }
          { name: 'seller3', param: 'seller3' }
        ]

        $scope.timeFilters = [
          { name: 'period1', param: 'period1' }
          { name: 'period1', param: 'period1' }
        ]

        $scope.productFilters = [
          { name: 'product1', param: 'product1' }
          { name: 'product2', param: 'product2' }
        ]

  ]
