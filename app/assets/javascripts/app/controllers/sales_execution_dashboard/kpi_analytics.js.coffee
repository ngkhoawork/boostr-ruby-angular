@app.controller 'KPIAnalyticsController',
  ['$scope', 'KPIDashboard', 'Team'
    ($scope, KPIDashboard, Team) ->

      #create chart===========================================================
      $scope.chartHeight= 500
      $scope.chartWidth = 1070
      $scope.chartMargin= 30
      $scope.scaleX = null
      $scope.scaleY = null
      $scope.svg = null
      $scope.teamFilters = []

      resetFilters = () ->
        $scope.sellerFilters = []
        $scope.timeFilters = []
        $scope.productFilters = []
        $scope.winRateData = []

      resetTables = () ->
        $scope.winRateData = []

      $scope.colors = ['blue', 'orange', 'green', 'grey', 'yellow', 'red', 'aqua', 'azure', 'black', 'brown']

      #init query
      KPIDashboard.get().$promise.then ((data) ->
        $scope.isTeamsNamesInWinRateTable = true
        Team.all(root_only: true).then ((teams) ->
          $scope.teams = teams
          createChart(data)
          initTablesData(data)

          $scope.teamFilters.push({name:'All', id:''})
          _.each teams, (team) ->
            $scope.teamFilters.push({name:team.name, id:team.id})
          ), (err) ->
            if err
              console.log(err)
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
        optimizedData = []
        i = 0
        len = data.win_rates.length
        while i < len
          item = {
            data: [],
            color: $scope.colors[i],
            label: data.win_rates[i][0],
          }
          _.each data.win_rates[i], (dataItem, index) ->
            if (dataItem.win_rate != undefined && dataItem.total_deals != undefined)
              dot = {x:index, y: dataItem.win_rate, r:dataItem.total_deals}
              if(dataItem.total_deals < 3.5)
                dot.r = 3.5
              item.data.push(dot)
          optimizedData.push(item)
          i++
        optimizedData

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
        maxValue = 100;
        #find min value for Y
        minValue = 0;

        #interpolate function for Y
        $scope.scaleY = d3.scale.linear()
          .domain([maxValue, minValue])
          .range([0, yAxisLength]);

        #interpolate function for Y
        $scope.scaleX = d3.scale.linear()
          .domain([0, time_periods.length])
          .range([0, xAxisLength]);

        # make X
        xAxis = d3.svg.axis()
          .scale($scope.scaleX)
          .orient('bottom')
          .tickFormat((d, i) ->
            time_periods[i-1]
          ).ticks(time_periods.length)

        #make Y
        yAxis = d3.svg.axis()
          .scale($scope.scaleY)
          .orient('left')
          .tickFormat((d) -> d + '%')

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
            i * 70
          )
          .attr('y', 0)
          .attr('width', 13)
          .attr('height', 13)
          .attr("rx", 4)
          .attr("ry", 4)
          .style 'fill', (d) ->
            d.color

        legend.append('text')
          .attr('x', (d, i) ->
            i * 70 + 20
          )
          .attr('y', 10)
          .attr('height', 30)
          .attr('width', 150)
          .text (d) ->
            d.label

      createChart = (data)->
        d3.select(".graph svg").remove();
        optimizeData = transformData(data)
        crateAxis(optimizeData, data.time_periods)
        _.each optimizeData, (chart) ->
          createItemChart(chart.data, chart.color, chart.label);


      #END create chart===========================================================
      #Filters====================================================================
      createFilters = (data) ->
        $scope.timeFilters = data.time_periods
        $scope.sellerFilters = [
          { name: 'seller1', param: 'seller1' }
          { name: 'seller2', param: 'seller2' }
          { name: 'seller3', param: 'seller3' }
        ]
      $scope.productFilters = [
        { name: 'product1', param: 'product1' }
        { name: 'product2', param: 'product2' }
      ]

      initTablesData = (data)->
        resetFilters()
        createFilters(data)
        resetTables()
        $scope.winRateTimePeriods = data.time_periods
        len = data.win_rates.length
        i = 0
        while i < len
          $scope.winRateData.push(data.win_rates[i])
          i++
        $scope.winRateAverage = data.average_win_rates

      $scope.filterByTeam =(id) ->
        if(id)
          KPIDashboard.get({team:id}).$promise.then ((data) ->
            $scope.isTeamsNamesInWinRateTable = false;
            createChart(data)
            initTablesData(data)
          ), (err) ->
            if err
              console.log(err)
        else
          KPIDashboard.get().$promise.then ((data) ->
            $scope.isTeamsNamesInWinRateTable = true;
            createChart(data)
            initTablesData(data)
          ), (err) ->
            if err
              console.log(err)

#=====END Filters====================================================================
  ]
