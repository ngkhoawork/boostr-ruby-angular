@app.controller 'KPIAnalyticsController',
  ['$scope', 'KPIDashboard', 'Team', 'Product', 'Field'
    ($scope, KPIDashboard, Team, Product, Field) ->

      #create chart===========================================================
      $scope.chartHeight= 500
      $scope.chartWidth = 1070
      $scope.chartMargin= 30
      $scope.scaleX = null
      $scope.scaleY = null
      $scope.svg = null
      $scope.teamFilters = []
      $scope.time_period = 'month'
      $scope.teamId = ''
      $scope.selectedTeam = {
        id:'all',
        name:'Team'
      }

      resetFilters = () ->
        $scope.sellerFilters = []
        $scope.timeFilters = []
        $scope.productFilters = []
        $scope.winRateData = []

      resetTables = () ->
        $scope.winRateData = []
        $scope.dealSizeData = []

      $scope.colors = ['blue', 'orange', 'green', 'grey', 'yellow', 'red', 'aqua', 'purple', 'black', 'brown']

      #init query
      KPIDashboard.get().$promise.then ((data) ->
        createChart(data)
        createDSChart(data)
        initTablesData(data)

        $scope.isTeamsNamesInWinRateTable = true

        Product.all().then (products) ->
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

        Team.all(all_teams: true).then ((teams) ->
          $scope.teams = teams
          $scope.teams.unshift({
            id:'all',
            name:'All'
          })

          $scope.teamFilters.push({name:'All', id:'all'})
          _.each teams, (team) ->
            $scope.teamFilters.push({name:team.name, id:team.id})
          ), (err) ->
            if err
              console.log(err)
      ), (err) ->
        if err
          console.log(err)

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

        if($scope.endDateIsValid && $scope.startDateIsValid  )
          query.start_date = $scope.start_date
          query.end_date = $scope.end_date

        KPIDashboard.get(query).$promise.then ((data) ->
          createChart(data)
          createDSChart(data)
          initTablesData(data)
        ), (err) ->
          if err
            console.log(err)

      #team watcher
      $scope.$watch 'selectedTeam', () ->
        $scope.teamId = $scope.selectedTeam.id
        getData()

#work with dates====================================================================
      $scope.endDateIsValid = undefined
      $scope.startDateIsValid = undefined

      $scope.$watch 'start_date', () ->
        checkDates()

      $scope.$watch 'end_date', () ->
        checkDates()

      checkDates = () ->
        end_date = new Date($scope.end_date).valueOf()
        start_date = new Date($scope.start_date).valueOf()

        if(end_date && start_date && end_date < start_date)
          $scope.endDateIsValid = false

        if(end_date && start_date && end_date > start_date)
          $scope.endDateIsValid = true
          $scope.startDateIsValid = true
          getData()
#Filters====================================================================
      createFilters = (data) ->
        $scope.timeFilters = data.time_periods
        $scope.sellerFilters = [
          { name: 'seller1', param: 'seller1' }
          { name: 'seller2', param: 'seller2' }
          { name: 'seller3', param: 'seller3' }
        ]

      initTablesData = (data)->
        resetFilters()
        createFilters(data)
        resetTables()
        $scope.winRateTimePeriods = data.time_periods
        #win rates table
        $scope.winRateData = data.win_rates
        $scope.winRateAverage = data.average_win_rates
        $scope.winRateAverage.unshift('Average')

        #dealSize table
        $scope.dealSizeData = data.average_deal_sizes
        $scope.dealSizeDataAverage = data.averaged_average_deal_sizes
        $scope.dealSizeDataAverage.unshift('Average')

      $scope.filterByTeam =(id) ->
        $scope.teamId = id
        getData()

      $scope.filterByPeriod =(period) ->
        $scope.time_period = period
        getData()

      $scope.resetDates = () ->
        $scope.start_date = null
        $scope.end_date = null
        $scope.endDateIsValid = undefined
        $scope.startDateIsValid = undefined
        getData()

      $scope.filterByProduct =(product) ->
        $scope.productFilter = product
        getData()

      $scope.filterByType =(type) ->
        $scope.typeFilter = type
        getData()

      $scope.filterBySource =(source) ->
        $scope.sourceFilter = source
        getData()

#=====END Filters====================================================================
#=======================WIN RATE=======================================================
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
              dot = {
                x:index,
                y: dataItem.win_rate,
                win_rate:dataItem.win_rate,
                wins:dataItem.won,
                loses:dataItem.lost
                seller:data.win_rates[i][0]
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
        average = {
          data: [],
          color: '#3498DB',
          label: 'Average',
        }
        _.each data.average_win_rates, (dataItem, index) ->
          if(data.average_win_rates.length-1 !=index )
            dot = {
              x:index+1,
              y: data.average_win_rates[index],
              r:3.5,
              win_rate:dataItem,
              wins:dataItem,
              loses:dataItem
              seller:'Average'
            }
            average.data.push(dot)
        optimizedData.unshift(average)
        optimizedData

      crateAxis = (data, time_periods) ->
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

        #interpolate function for Y
        $scope.scaleY = d3.scale.linear()
          .domain([maxValue, minValue])
          .range([0, yAxisLength])

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
          )
          .tickPadding(10)
          .ticks(time_periods.length)

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

        #paint gorizontal lines
        d3.selectAll('g.y-axis g.tick')
          .append('line').classed('grid-line', true)
          .attr('x1', 0)
          .attr('y1', 0)
          .attr('x2', xAxisLength)
          .attr('y2', 0)

        #add legend
        legendTable = d3.select(".win-rate svg").append("g")
          .attr("transform", "translate(70, "+($scope.chartHeight+15)+")")
          .attr("class", "legendTable");
        legend = legendTable.selectAll('.legend')
          .data(data).enter()
          .append('g')
          .attr('class', 'legend')
          .attr('transform', (d, i) ->
            if (i>5)
              i = i-6
            return 'translate(' + i * 100 + ', 0)'
          )

        legend.append('rect')
          .attr('x', (d, i) ->
            if(i<6)
              return i * 70
            else
              return (i-6) * 70
          )
          .attr('y', (d, i) ->
            if(i<6)
              return 0
            else
              return 20
          )
          .attr('width', 13)
          .attr('height', 13)
          .attr("rx", 4)
          .attr("ry", 4)
          .style 'fill', (d) ->
            d.color

        legend.append('text')
          .attr('x', (d, i) ->
            if(i<6)
              return i * 70 + 20
            else
              return (i-6) * 70 + 20
          )
          .attr('y', (d, i) ->
            if(i<6)
              return 10
            else
              return 30
           )
          .attr('height', 30)
          .attr('width', 150)
          .text (d) ->
            d.label

      createChart = (data)->
        d3.select(".win-rate svg").remove();
        optimizeData = transformData(data)
        crateAxis(optimizeData, data.time_periods)
        _.each optimizeData, (chart) ->
          createItemChart(chart.data, chart.color, chart.color.replace(/#/, ''));


#=======================END WIN RATE=======================================================
#=======================DEAl SIZE=======================================================
      createDSItemChart = (data, colorStroke, label) ->
      # make lines function
        line = d3.svg.line().interpolate('monotone').x((d) ->
          $scope.scaleDSX(d.x) + $scope.chartMargin
        ).y((d) ->
          $scope.scaleDSY(d.y) + $scope.chartMargin
        )
        g = $scope.svgDS.append('g')
        g.append('path')
        .attr('d', line(data))
        .style('stroke', colorStroke)
        .style('stroke-width', 2)

        #Define the div for the tooltip
        div = d3.select(".deal-size").append("div")
        .attr("class", "tooltip")
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
          div.transition().duration(200).style 'opacity', 1
          div.html('<p>'+ d.seller + '</p><p><span>$' + d.win_rate + '</span><span>' +d.wins+ '</span></p><p><span>Deal Size</span><span>Wins</span></p>')
          .style('left', $scope.scaleDSX(d.x) + $scope.chartMargin - 115 + 'px')
          .style('top', $scope.scaleDSY(d.y) + $scope.chartMargin + 18 + 'px')
        ).on 'mouseout', (d) ->
          div.transition().duration(500).style 'opacity', 0

      transformDSData = (data) ->
        optimizedData = []
        i = 0
        len = data.average_deal_sizes.length
        while i < len
          item = {
            data: [],
            color: $scope.colors[i],
            label: data.average_deal_sizes[i][0],
          }
          _.each data.average_deal_sizes[i], (dataItem, index) ->
            if (dataItem.average_deal_size != undefined && dataItem.total_deals != undefined)
              dot = {
                x:index,
                y: dataItem.average_deal_size,
                win_rate:dataItem.average_deal_size,
                wins:dataItem.won || 0,
                seller:data.win_rates[i][0]
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
        average = {
          data: [],
          color: '#3498DB',
          label: 'Average',
        }
        _.each data.average_win_rates, (dataItem, index) ->
          if(data.average_win_rates.length-1 !=index )
            dot = {
              x:index+1,
              y: data.average_win_rates[index],
              r:3.5,
              win_rate:dataItem,
              wins:dataItem,
              loses:dataItem
              seller:'Average'
            }
            average.data.push(dot)
        optimizedData.unshift(average)
        optimizedData

      crateDSAxis = (data, time_periods) ->
        $scope.svgDS = d3.select(".deal-size").append("svg")
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

        #find min value for Y
        minValue = 0;

        #interpolate function for Y
        $scope.scaleDSY = d3.scale.linear()
        .domain([maxValue, minValue])
        .range([0, yAxisLength])

        #interpolate function for Y
        $scope.scaleDSX = d3.scale.linear()
        .domain([0, time_periods.length])
        .range([0, xAxisLength]);

        # make X
        xAxis = d3.svg.axis()
        .scale($scope.scaleDSX)
        .orient('bottom')
        .tickFormat((d, i) ->
          time_periods[i-1]
        )
        .tickPadding(10)
        .ticks(time_periods.length)

        #make Y
        yAxis = d3.svg.axis()
        .scale($scope.scaleDSY)
        .orient("left")
        .tickFormat((d) -> d + "$");

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

        #paint gorizontal lines
        d3.selectAll('g.y-axis g.tick')
        .append('line').classed('grid-line', true)
        .attr('x1', 0)
        .attr('y1', 0)
        .attr('x2', xAxisLength)
        .attr('y2', 0)

        #add legend
        legendTable = d3.select(".deal-size svg").append("g")
        .attr("transform", "translate(70, "+($scope.chartHeight+15)+")")
        .attr("class", "legendTable");
        legend = legendTable.selectAll('.legend')
        .data(data).enter()
        .append('g')
        .attr('class', 'legend')
        .attr('transform', (d, i) ->
          if (i>5)
            i = i-6
          return 'translate(' + i * 100 + ', 0)'
        )

        legend.append('rect')
        .attr('x', (d, i) ->
          if(i<6)
            return i * 70
          else
            return (i-6) * 70
        )
        .attr('y', (d, i) ->
          if(i<6)
            return 0
          else
            return 20
        )
        .attr('width', 13)
        .attr('height', 13)
        .attr("rx", 4)
        .attr("ry", 4)
        .style 'fill', (d) ->
          d.color

        legend.append('text')
        .attr('x', (d, i) ->
          if(i<6)
            return i * 70 + 20
          else
            return (i-6) * 70 + 20
        )
        .attr('y', (d, i) ->
          if(i<6)
            return 10
          else
            return 30
        )
        .attr('height', 30)
        .attr('width', 150)
        .text (d) ->
          d.label

      createDSChart = (data)->
        d3.select(".deal-size svg").remove();
        optimizeData = transformDSData(data)
        crateDSAxis(optimizeData, data.time_periods)
        _.each optimizeData, (chart) ->
          createDSItemChart(chart.data, chart.color, chart.color.replace(/#/, ''));


#=======================END DEAL SIZE=======================================================
  ]
