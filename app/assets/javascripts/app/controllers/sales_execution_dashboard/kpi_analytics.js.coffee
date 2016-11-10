@app.controller 'KPIAnalyticsController',
  ['$scope', 'KPIDashboard',
    ($scope, KPIDashboard) ->

#      KPIDashboard.get().$promise.then ((defaultData) ->
#        console.log(defaultData)
#      ), (err) ->
#        if err
#          console.log(err)

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

      data = {
        "win_rates":["West Coast Sales","West Coast Member User",4.1,3.4,5.1,3.4,1.4,5.1,6],
        "time_periods":["May","June","July","August","September","October"],
        "average_win_rates":[5,20,30,10,0,50,8]
      }

      height = 500
      width = 1070
      margin=30
      usdData = [
        {x:1, y: 42, r:5},
        {x:2, y: 50, r:5},
        {x:3, y: 10, r:5},
        {x:4, y: 50, r:5},

      ]
      eurData = [
        {x:1, y: 42, r:5},
        {x:2, y: 4, r:5},
        {x:3, y: 15, r:5},
        {x:4, y: 55, r:5},

      ]
      tData = [
        {x:1, y: 37, r:5},
        {x:2, y: 41, r:5},
        {x:3, y: 22, r:5},
        {x:4, y: 6, r:5},

      ]
      legendData = [
        {color:"steelblue", name:'bbbb'},
        {color:"green", name:'hhhh'},
        {color:"orange", name:'aaaaa'}
      ]

      svg = d3.select(".graph").append("svg")
        .attr("class", "axis")
        .attr("width", width)
        .attr("height", height);

      #length X = width svg container - margin left and right
      xAxisLength = width - 2 * margin;
      #length Y = height svg container -  margin top and bottom
      yAxisLength = height - 2 * margin;
      #find max value for Y
      maxValue = 80;
      #find min value for Y
      minValue = 0;

      #interpolate function for Y
      scaleY = d3.scale.linear()
        .domain([maxValue, minValue])
        .range([0, yAxisLength]);

      #interpolate function for Y
      scaleX = d3.scale.linear()
        .domain([0, 4])
        .range([0, xAxisLength]);

      # make X
      xAxis = d3.svg.axis()
        .scale(scaleX)
        .orient('bottom')
        .tickFormat((d, i) ->
          data.time_periods[i - 1] or 0
        ).ticks(4)

      #make Y
      yAxis = d3.svg.axis()
        .scale(scaleY)
        .orient('left')

      #paint Х
      svg.append('g')
        .attr('class', 'x-axis')
        .attr('transform', 'translate(' + margin + ',' + (height - margin) + ')')
        .call xAxis

      #paint Y
      svg.append('g').attr('class', 'y-axis')
        .attr('transform', 'translate(' + margin + ',' + margin + ')')
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
        .attr("transform", "translate(70, "+(height+15)+")")
        .attr("class", "legendTable");
      legend = legendTable.selectAll('.legend')
        .data(legendData).enter()
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
          d.name

      createChart = (data, colorStroke, label) ->
        # make lines function
        line = d3.svg.line().interpolate('monotone').x((d) ->
          scaleX(d.x) + margin
        ).y((d) ->
          scaleY(d.y) + margin
        )
        g = svg.append('g')
        g.append('path')
          .attr('d', line(data))
          .style('stroke', colorStroke)
          .style('stroke-width', 2)
        # dots
        svg.selectAll('.dot ' + label)
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
            scaleX(d.x) + margin
          ).attr 'cy', (d) ->
            scaleY(d.y) + margin
        return

      createChart(usdData, "steelblue", "usd");
      createChart(eurData, "green", "euro");
      createChart(tData, "orange", "euro");
  ]
