@app.controller 'PMPController',
  ['$rootScope', '$scope', '$modal', '$location', '$filter', '$timeout', '$routeParams', 'PMP', 'PMPMember', 'User', 'PMPItem', 'PMPItemDailyActual', 'PMPType',
  ( $rootScope,   $scope,   $modal,   $location,   $filter,   $timeout,   $routeParams,   PMP,   PMPMember,   User,   PMPItem,   PMPItemDailyActual,   PMPType) ->
    $scope.currentPMP = {}
    $scope.currency_symbol = '$'
    $scope.selectedDeliveryItem = {}
    $scope.selectedPriceItem = {}
    $scope.pmpItemDailyActuals = []
    $scope.isLoading = false
    $scope.allDataLoaded = false
    $scope.page = 1
    $scope.PMPType = PMPType
    $scope.timeFilter = {
      timePeriodString: ''
      timePeriod: {
        startDate: null
        endDate: null
      }      
      updateCharts: () ->
        $scope.updateRevenueChart()
        $scope.updateDeliveryChart()
        $scope.updatePriceChart()
      applyTimePeriod: () ->
        d = $scope.timeFilter.timePeriod
        if d.startDate && d.endDate
          $scope.timeFilter.savedTimePeriod = angular.copy d
        else if $scope.timeFilter.savedTimePeriod
          d.startDate = $scope.timeFilter.savedTimePeriod.startDate
          d.endDate = $scope.timeFilter.savedTimePeriod.endDate
        if d.startDate && d.endDate
          $scope.timeFilter.timePeriodString = d.startDate.format('MMM D, YY') + ' - ' + d.endDate.format('MMM D, YY')
          $scope.timeFilter.updateCharts()
      removeTimePeriod: (e) ->
        e.stopPropagation()
        $scope.timeFilter.timePeriod = {startDate: null, endDate: null}
        $scope.timeFilter.timePeriodString = ''
        $scope.timeFilter.updateCharts()
    }
    $scope.revenueFilter = {
      item: null
      id: () ->
        id = if $scope.revenueFilter.item == 'all' then 'all' else $scope.revenueFilter.item.id
        id + $scope.timeFilter.timePeriodString
    }
    graphData = {}
    graphRevenueData = {}
    
    init = () ->
      PMP.get($routeParams.id).then (pmp) ->
        $scope.currentPMP = pmp
        $scope.updateDeliveryChart('all')
        $scope.updatePriceChart('all')
        $scope.updateRevenueChart('all', 'item')
        $scope.currency_symbol = pmp.currency && (pmp.currency.curr_symbol || pmp.currency.curr_cd)

    reloadDailyActuals = () ->
      $scope.page = 1
      $scope.pmpItemDailyActuals = []
      $scope.loadMoreData()

    $scope.loadMoreData = ->
      return if $scope.isLoading
      $scope.isLoading = true
      PMPItemDailyActual.all(pmp_id: $routeParams.id, page: $scope.page++).then (data) ->
        $scope.allDataLoaded = !data.length
        $scope.pmpItemDailyActuals = $scope.pmpItemDailyActuals.concat data
        $timeout -> $scope.isLoading = false

    $scope.deleteMember = (pmp_member) ->
      if confirm('Are you sure you want to delete "' + pmp_member.name + '"?')
        PMPMember.delete(id: pmp_member.id, pmp_id: $scope.currentPMP.id).then (pmp) ->
          $scope.currentPMP = pmp

    $scope.showLinkExistingUser = ->
      User.query().$promise.then (users) ->
        $scope.users = $filter('notIn')(users, $scope.currentPMP.pmp_members, 'user_id')

    $scope.linkExistingUser = (item) ->
      $scope.userToLink = undefined
      PMPMember.create(
        pmp_id: $scope.currentPMP.id,
        pmp_member: {
          user_id: item.id,
          share: 0,
          from_date: $scope.currentPMP.start_date,
          to_date: $scope.currentPMP.end_date,
          values: []
        }).then (pmp) ->
          $scope.currentPMP = pmp

    $scope.updatePMPMember = (data) ->
      PMPMember.update(id: data.id, pmp_id: $scope.currentPMP.id, pmp_member: data).then (pmp) ->
        $scope.currentPMP = pmp

    $scope.updateDeliveryChart = (pmpItem) ->
      if pmpItem
        $scope.selectedDeliveryItem = pmpItem
      id = if $scope.selectedDeliveryItem == 'all' then 'all' else $scope.selectedDeliveryItem.id
      id = id + $scope.timeFilter.timePeriodString
      if graphData[id]
        drawChart(graphData[id], '#pmp-delivery-chart-container', '#pmp-delivery-chart')
      else if $scope.timeFilter.timePeriodString
        PMPItemDailyActual.aggregate(pmp_id: $routeParams.id, pmp_item_id: $scope.selectedDeliveryItem.id || 'all', group_by: 'date', start_date: $scope.timeFilter.timePeriod.startDate, end_date: $scope.timeFilter.timePeriod.endDate).then (data) ->
          if data && data.length > 0
            graphData[id] = data
          drawChart(data, '#pmp-delivery-chart-container', '#pmp-delivery-chart')
      else 
        drawChart([], '#pmp-delivery-chart-container', '#pmp-delivery-chart')

    $scope.updatePriceChart = (pmpItem) ->
      if pmpItem
        $scope.selectedPriceItem = pmpItem
      id = if $scope.selectedPriceItem == 'all' then 'all' else $scope.selectedPriceItem.id
      id = id + $scope.timeFilter.timePeriodString
      if graphData[id]
        drawChart(graphData[id], '#pmp-price-revenue-chart-container', '#pmp-price-revenue-chart')
      else if $scope.timeFilter.timePeriodString
        PMPItemDailyActual.aggregate(pmp_id: $routeParams.id, pmp_item_id: $scope.selectedPriceItem.id || 'all', group_by: 'date', start_date: $scope.timeFilter.timePeriod.startDate, end_date: $scope.timeFilter.timePeriod.endDate).then (data) ->
          if data && data.length > 0
            graphData[id] = data
          drawChart(data, '#pmp-price-revenue-chart-container', '#pmp-price-revenue-chart')
      else
        drawChart([], '#pmp-price-revenue-chart-container', '#pmp-price-revenue-chart')

    $scope.updateRevenueChart = (val, id) ->
      if id
        $scope.revenueFilter[id] = val
      id = $scope.revenueFilter.id()
      if graphRevenueData[id]
        drawRevenueChart(graphRevenueData[id], '#pmp-revenue-advertiser-chart-container', '#pmp-revenue-advertiser-chart')
      else if $scope.timeFilter.timePeriodString
        PMPItemDailyActual.aggregate(pmp_id: $routeParams.id, pmp_item_id: $scope.revenueFilter.item.id || 'all', group_by: 'advertiser', start_date: $scope.timeFilter.timePeriod.startDate, end_date: $scope.timeFilter.timePeriod.endDate).then (data) ->
          if data && data.length > 0
            graphRevenueData[id] = data
          drawRevenueChart(data, '#pmp-revenue-advertiser-chart-container', '#pmp-revenue-advertiser-chart')
      else
        drawRevenueChart([], '#pmp-revenue-advertiser-chart-container', '#pmp-revenue-advertiser-chart')

    drawRevenueChart = (data, containerID, svgID) ->
      chartContainer = angular.element(containerID)
      margin =
          top: 35
          left: 85
          right: 85
          bottom: 25
      miniMargin = 
          top: 20
          left: 85
          right: 85
          bottom: 10
      duration = 1000
      ratio = 0.35
      miniRatio = 0.05
      miniWidth = chartContainer.width() - miniMargin.left - miniMargin.right || 800
      miniHeight = 60
      width = chartContainer.width() - margin.left - margin.right || 800
      height = chartContainer.width()*ratio - margin.top - margin.bottom - miniHeight - miniMargin.top - miniMargin.bottom
      data = _.map data, (d) -> 
        d.revenue_loc = parseFloat(d.revenue_loc)
        d
      data = _.sortBy data, (d) -> -d.revenue_loc
      return d3.select(svgID).html('') if data.length == 0

      update = () ->
        c = d3.scale.category10()
        bar = mainGroup.selectAll(".bar")
            .data(data)

        bar.attr("x", (d,i) -> x(d.advertiser.name))
          .attr("width", x.rangeBand())
          .attr("y", (d) -> y(d.revenue_loc))
          .transition().duration(50)
          .attr("height", (d) -> height - y(d.revenue_loc))

        bar.enter().append("rect")
          .attr("class", "bar")
          .style("fill", (d) -> c(Math.random()*10))
          .attr("x", (d,i) -> x(d.advertiser.name))
          .attr("width", x.rangeBand())
          .attr("y", (d) -> y(d.revenue_loc))
          .transition().duration(50)
          .attr("height", (d) -> height - y(d.revenue_loc))
          .style('cursor', 'pointer')

        bar.exit()
          .remove()

      brushmove = () ->
        extent = brush.extent()

        selected = miniX.domain()
          .filter((d) -> (extent[0] - miniX.rangeBand() + 1e-2 <= miniX(d)) && (miniX(d) <= extent[1] - 1e-2)) 

        miniGroup.selectAll(".bar")
          .style("fill", (d, i) -> "#e0e0e0")

        d3.selectAll(svgID + " .axisX text")
          .style("font-size", textScale(selected.length))
        
        originalRange = mainXZoom.range()
        mainXZoom.domain( extent )

        x.domain(data.map((d) -> d.advertiser.name))
        x.rangeBands( [ mainXZoom(originalRange[0]), mainXZoom(originalRange[1]) ], 0.4, 0)

        mainGroup.select(".axisX")
          .call(xAxis)

        # newMaxYScale = d3.max(data, (d) -> if selected.indexOf(d.advertiser.name) > -1 then d.revenue_loc else 0)
        # y.domain([0, newMaxYScale])

        mainGroupWrapper.select(".axisY")
          .transition().duration(50)
          .call(yAxis)

        update()

      brushcenter = () -> 
        target = d3.event.target
        extent = brush.extent()
        size = extent[1] - extent[0]
        range = miniX.range()
        x0 = d3.min(range) + size / 2
        x1 = d3.max(range) + miniX.rangeBand() - size / 2
        center = Math.max( x0, Math.min( x1, d3.mouse(target)[0] ) )

        d3.event.stopPropagation()

        gBrush
            .call(brush.extent([center - size / 2, center + size / 2]))
            .call(brush.event)

      scroll = () ->
        extent = brush.extent()
        size = extent[1] - extent[0]
        range = miniX.range()
        x0 = d3.min(range)
        x1 = d3.max(range) + miniX.rangeBand()
        dx = d3.event.deltaY
        topSection = null

        if extent[0] - dx < x0
          topSection = x0
        else if extent[1] - dx > x1
          topSection = x1 - size 
        else
          topSection = extent[0] - dx

        d3.event.stopPropagation()
        d3.event.preventDefault()

        gBrush
            .call(brush.extent([ topSection, topSection + size ]))
            .call(brush.event)

      zoomer = d3.behavior.zoom().on("zoom", null)

      svg = d3.select(svgID)
              .attr("preserveAspectRatio", "xMinYMin meet")
              .attr("viewBox", "0 0 " + (width + margin.left + margin.right) + " " + (height + margin.top + margin.bottom + miniHeight + miniMargin.top + miniMargin.bottom))
              .call(zoomer)
              .on("wheel.zoom", scroll)
              .on("mousedown.zoom", null)
              .on("touchstart.zoom", null)
              .on("touchmove.zoom", null)
              .on("touchend.zoom", null)
              .html('')
      mainGroupWrapper = svg.append('g')            
                    .attr("class","mainGroupWrapper")                                                               
                    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
      mainGroup = mainGroupWrapper.append("g")
                    .attr("clip-path", "url(#clip)")
                    .style("clip-path", "url(#clip)")
                    .attr("class", "mainGroup")
      miniGroup = svg.append("g")
                    .attr("class", "miniGroup")
                    .attr("transform", "translate(" + miniMargin.left + "," + (margin.top + height + margin.bottom + miniMargin.top) + ")")
      brushGroup = svg.append(                                                                                                        "g")
                    .attr("class", "brushGroup")
                    .attr("transform", "translate(" + miniMargin.left + "," + (margin.top + height + margin.bottom + miniMargin.top) + ")")

      # Axes
      mainGroup.append('line')
          .style('stroke', '#d9dde0')
          .attr('x1', 0)
          .attr('y1', 0)
          .attr('x2', 0)
          .attr('y2', height + 80)
      mainGroup.append('line')
          .style('stroke', '#d9dde0')
          .attr('x1', 0)
          .attr('y1', height)
          .attr('x2', width)
          .attr('y2', height)

      x = d3.scale.ordinal().rangeBands([0, width], 0.4, 0)
      miniX = d3.scale.ordinal().rangeBands([0, miniWidth], 0.4, 0)
      y = d3.scale.linear().range([height, 0])
      miniY = d3.scale.linear().range([miniHeight, 0])

      mainXZoom = d3.scale.linear()
        .range([0, width])
        .domain([0, width])

      xAxis = d3.svg.axis().scale(x).orient('bottom')
              .outerTickSize(0)
              .innerTickSize(0)
              .tickPadding(10)
      mainGroup.append('g')
        .attr('class', 'axisX axis')
        .attr('transform', 'translate(0,' + height + ')')

      yAxis = d3.svg.axis().scale(y).orient('left')
              .innerTickSize(-width)
              .outerTickSize(0)
              .tickFormat (v) -> 
                $scope.currency_symbol + $filter('number')(v)
      mainGroupWrapper.insert('g', ':first-child')
        .attr('class', 'axisY axis')

      y.domain([0, d3.max(data, (d) -> d.revenue_loc)*1.1])
      miniY.domain([0, d3.max(data, (d) -> d.revenue_loc)*1.1])
      x.domain(data.map((item) -> item.advertiser.name))
      miniX.domain(data.map((item) -> item.advertiser.name))

      mainGroup.select("axisX").call(xAxis)

      textScale = d3.scale.linear()
        .domain([15,50])
        .range([12,6])
        .clamp(true)

      brushExtent = Math.max( 1, Math.min( 20, Math.round(data.length*0.2) ) )
      lastExtent = if data.length <= 7 then miniWidth else miniX(data[brushExtent].advertiser.name)

      brush = d3.svg.brush()
          .x(miniX)
          .extent([miniX(data[0].advertiser.name), lastExtent])
          .on("brush", brushmove)

      gBrush = brushGroup.append("g")
        .attr("class", "brush")
        .call(brush)
      
      gBrush.selectAll(".resize")
        .append("line")
        .attr("y2", miniHeight)

      gBrush.selectAll(".resize")
        .append("path")
        .attr("d", d3.svg.symbol().type("triangle-up").size(20))
        .attr("transform", (d,i) -> 
          if i then "translate(" + -4 + "," + (miniHeight/2) + ") rotate(270)" else "translate(" + 4 + "," + (miniHeight/2) + ") rotate(90)"
        )

      gBrush.selectAll("rect")
        .attr("height", miniHeight);

      gBrush.select(".background")
        .on("mousedown.brush", brushcenter)
        .on("touchstart.brush", brushcenter);

      defs = svg.append("defs")

      defs.append("clipPath")
        .attr("id", "clip")
        .append("rect")
        .attr("x", 0)
        .attr("y", 0)
        .attr("width", width)
        .attr("height", height + margin.bottom)

      miniBar = miniGroup.selectAll(".bar")
        .data(data)

      miniBar
        .attr("height", (d) -> miniY(d.revenue_loc))
        .attr("x", (d,i) -> miniX(d.advertiser.name))
        .attr("width", miniX.rangeBand())

      miniBar.enter().append("rect")
        .attr("class", "bar")
        .attr("y", (d) -> miniY(d.revenue_loc))
        .attr("height", (d) -> miniHeight - miniY(d.revenue_loc))
        .attr("x", (d,i) -> miniX(d.advertiser.name))
        .attr("width", miniX.rangeBand())

      miniBar.exit()
        .remove()

      gBrush.call(brush.event)

      # Tooltip
      tooltipText = (selectedItem, unit, d, title) ->
        value = 'N/A'
        if d?
          if unit == $scope.currency_symbol
            value = unit + $filter('number')(d) 
          else 
            value = $filter('number')(d) + unit
        '<p>' + (selectedItem.ssp_deal_id || $filter('firstUppercase')(selectedItem)) + '</p>' + 
        '<p><span>' + value + '</span></p>' + 
        '<p><span>' + title + '</span></p>'
      tooltip = d3.select("body").append("div") 
          .attr("class", "pmp-chart-tooltip")             
          .style("opacity", 0)
      mouseOut = (d) ->
        d3.select(this).transition().duration(500).attr("r", 4)   
        tooltip.transition()        
            .duration(500)      
            .style("opacity", 0);
      mouseOver = (unit) ->
        selectedItem = $scope.revenueFilter.item
        return (d) ->
          d3.select(this).transition().duration(500).attr("r", 6)     
          tooltip.transition()        
              .duration(200)      
              .style("opacity", .9);      
          tooltip.html(tooltipText(selectedItem, unit, d.revenue_loc, d.advertiser.name))  
              .style("left", (d3.event.pageX) - 50 + "px")     
              .style("top", (d3.event.pageY + 18) + "px")
      mouseMove = (d) ->
        tooltip.style("left", (d3.event.pageX) - 50 + "px")     
              .style("top", (d3.event.pageY + 18) + "px")

      svg.selectAll('.bar')   
              .on('mouseover', mouseOver($scope.currency_symbol))
              .on('mouseout', mouseOut) 
              .on('mousemove', mouseMove) 

    getGraphData = (data, attr) ->
      _.reduce(data, (arr, row) ->
        if row[attr]?
          arr.push(parseFloat(row[attr]))
        else
          arr.push null
        arr
      , [])

    getPriceGraphData = (data) ->
      _.reduce(data, (arr, row) ->
        if row['revenue_loc']? && row['impressions']? && parseFloat(row['impressions']) != 0
          arr.push Math.floor(parseFloat(row['revenue_loc']) / parseFloat(row['impressions']) * 1000 * 100) / 100
        else
          arr.push null
        arr
      , [])

    getGraphDataSet = (data, svgID) ->
      c = d3.scale.category10()
      switch svgID
        when '#pmp-delivery-chart'
          [
            {name: 'Requests', graphType: 1, hideTitle: true, active: true, unit: '', color: c(0), values: getGraphData(data, 'ad_requests')}
            {name: 'Impressions', graphType: 1, active: true, unit: '', color: c(1), values: getGraphData(data, 'impressions')}    
            {name: 'Win Rate', graphType: 2, active: true, unit: '%', color: c(2), values: getGraphData(data, 'win_rate')}      
          ]
        when '#pmp-price-revenue-chart'
          [
            {name: 'Price', graphType: 1, active: true, unit: $scope.currency_symbol, color: c(0), values: getPriceGraphData(data)}
            {name: 'Revenue', graphType: 2, active: true, unit: $scope.currency_symbol, color: c(1), values: getGraphData(data, 'revenue_loc')}          
          ]
        when '#pmp-revenue-advertiser-chart'
          [
            {name: 'Revenue', active: true, unit: $scope.currency_symbol, color: c(0), values: getGraphData(data, 'revenue_loc')}
          ]
        else []

    drawChart = (data, containerID, svgID) ->
      chartContainer = angular.element(containerID)
      margin =
          top: 35
          left: 85
          right: 85
          bottom: 80
      miniMargin = 
          top: 20
          left: 85
          right: 85
          bottom: 50
      duration = 1000
      ratio = 0.35
      ticks = 11
      miniWidth = chartContainer.width() - miniMargin.left - miniMargin.right || 800
      miniHeight = 60
      width = chartContainer.width() - margin.left - margin.right || 800
      height = chartContainer.width()*ratio - margin.top - margin.bottom - miniHeight - miniMargin.top - miniMargin.bottom
      data = data.sort (a,b) -> new Date(a.date) - new Date(b.date)
      days = data.map (item) -> item.date
      dataset = getGraphDataSet(data, svgID)
      return if dataset.length == 0 

      # Tooltip
      tooltipText = (selectedItem, unit, d, title) ->
        value = 'N/A'
        if d?
          if unit == $scope.currency_symbol
            value = unit + $filter('number')(d) 
          else 
            value = $filter('number')(d) + unit
        '<p>' + (selectedItem.ssp_deal_id || $filter('firstUppercase')(selectedItem)) + '</p>' + 
        '<p><span>' + value + '</span></p>' + 
        '<p><span>' + title + '</span></p>'
      tooltip = d3.select("body").append("div") 
          .attr("class", "pmp-chart-tooltip")             
          .style("opacity", 0)
      mouseOut = (d) ->
        d3.select(this).transition().duration(500).attr("r", 4)   
        tooltip.transition()        
            .duration(500)      
            .style("opacity", 0);
      mouseOver = (title, unit) ->
        selectedItem = if svgID == '#pmp-delivery-chart' then $scope.selectedDeliveryItem else $scope.selectedPriceItem
        return (d) ->
          d3.select(this).transition().duration(500).attr("r", 6)     
          tooltip.transition()        
              .duration(200)      
              .style("opacity", .9);      
          tooltip.html(tooltipText(selectedItem, unit, d, title))  
              .style("left", (d3.event.pageX) - 50 + "px")     
              .style("top", (d3.event.pageY + 18) + "px")

      update = () ->
        c = d3.scale.category10()
        graphLine1 = d3.svg.line()
                .x((value, i) -> x(days[i]))
                .y((value, i) -> y1(value))
                .defined((value, i) -> _.isNumber value)
        graphLine2 = d3.svg.line()
                .x((value, i) -> x(days[i]))
                .y((value, i) -> y2(value))
                .defined((value, i) -> _.isNumber value)

        graph = mainGroup.selectAll('.graph')
              .data(dataset)

        graph.attr 'd', (d) -> if d.graphType==2 then graphLine2(d.values) else graphLine1(d.values)

        graph.enter()
              .append('path')
              .attr 'class', (d) -> 'graph graph-'+d.name.replace(' ', '_')
              .attr 'stroke', (d) -> d.color
              .attr 'd', -> graphLine1(_.map days, -> 0)
              .transition()
              .duration(duration)
              .attr 'd', (d) -> if d.graphType==2 then graphLine2(d.values) else graphLine1(d.values)

        for d in dataset
          dot = mainGroup.selectAll("circle.graph-" + d.name.replace(' ', '_'))
              .data(d.values)

          dot.attr("cx", (v, i) -> x(days[i]))       
              .attr("cy", (v) -> if d.graphType == 1 then y1(v) else y2(v))

          dot.enter()
              .append("circle") 
              .attr('class', "graph-" + d.name.replace(' ', '_'))
              .style("cursor", "pointer")  
              .attr("fill", d.color)                              
              .attr("r", 4)       
              .attr("cx", (v, i) -> x(days[i]))       
              .attr("cy", (v) -> if d.graphType == 1 then y1(v) else y2(v))
              .on("mouseover", mouseOver(d.name, d.unit))
              .on("mouseout", mouseOut)
              .style("opacity", 0)
              .transition()
              .duration(500)
              .style("opacity", 1)          

        graph.exit().remove()

      brushmove = () ->
        extent = brush.extent()

        selected = miniX.domain()
          .filter((d) -> (extent[0] - miniX.rangeBand() + 1e-2 <= miniX(d)) && (miniX(d) <= extent[1] - 1e-2)) 

        miniGroup.selectAll(".graph")
          .style("stroke", (d, i) -> "#e0e0e0")

        d3.selectAll(svgID + " .axisX text")
          .style("font-size", textScale(selected.length))
        
        originalRange = mainXZoom.range()
        mainXZoom.domain( extent )

        x.domain(days)
        x.rangeBands( [ mainXZoom(originalRange[0]), mainXZoom(originalRange[1]) ], 0.4, 0.4)

        mainGroup.select(".axisX")
          .call(xAxis)
          .selectAll("text")  
          .style("text-anchor", "end")
          .attr("dx", "-.8em")
          .attr("dy", "-1.6em")
          .attr("transform", "rotate(-90)")

        # newMaxYScale = d3.max(data, (d) -> if selected.indexOf(d.advertiser.name) > -1 then d.revenue_loc else 0)
        # y.domain([0, newMaxYScale])

        mainGroupWrapper.select(".axisY1")
          .transition().duration(50)
          .call(y1Axis)
        mainGroupWrapper.select(".axisY2")
          .transition().duration(50)
          .call(y2Axis)

        update()

      brushcenter = () -> 
        target = d3.event.target
        extent = brush.extent()
        size = extent[1] - extent[0]
        range = miniX.range()
        x0 = d3.min(range) + size / 2
        x1 = d3.max(range) + miniX.rangeBand() - size / 2
        center = Math.max( x0, Math.min( x1, d3.mouse(target)[0] ) )

        d3.event.stopPropagation()

        gBrush
            .call(brush.extent([center - size / 2, center + size / 2]))
            .call(brush.event)

      scroll = () ->
        extent = brush.extent()
        size = extent[1] - extent[0]
        range = miniX.range()
        x0 = d3.min(range)
        x1 = d3.max(range) + miniX.rangeBand()
        dx = d3.event.deltaY
        topSection = null

        if extent[0] - dx < x0
          topSection = x0
        else if extent[1] - dx > x1
          topSection = x1 - size 
        else
          topSection = extent[0] - dx

        d3.event.stopPropagation()
        d3.event.preventDefault()

        gBrush
            .call(brush.extent([ topSection, topSection + size ]))
            .call(brush.event)

      zoomer = d3.behavior.zoom().on("zoom", null)

      svg = d3.select(svgID)
              .attr("preserveAspectRatio", "xMinYMin meet")
              .attr("viewBox", "0 0 " + (width + margin.left + margin.right) + " " + (height + margin.top + margin.bottom + miniHeight + miniMargin.top + miniMargin.bottom))
              .call(zoomer)
              .on("wheel.zoom", scroll)
              .on("mousedown.zoom", null)
              .on("touchstart.zoom", null)
              .on("touchmove.zoom", null)
              .on("touchend.zoom", null)
              .html('')


      mainGroupWrapper = svg.append('g')            
                    .attr("class","mainGroupWrapper")                                                               
                    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
      mainGroup = mainGroupWrapper.append("g")
                    .attr("clip-path", "url(" + svgID + "-clip)")
                    .style("clip-path", "url(" + svgID + "-clip)")
                    .attr("class", "mainGroup")
      miniGroup = svg.append("g")
                    .attr("class", "miniGroup")
                    .attr("transform", "translate(" + miniMargin.left + "," + (margin.top + height + margin.bottom + miniMargin.top) + ")")
      brushGroup = svg.append("g")
                    .attr("class", "brushGroup")
                    .attr("transform", "translate(" + miniMargin.left + "," + (margin.top + height + margin.bottom + miniMargin.top) + ")")

      # Axes
      arr = dataset.filter((d) -> d.graphType==1)
      maxValue = d3.max(arr, (item) -> d3.max item.values) || 50
      y1Max = Math.max(100, Math.ceil(maxValue*1.2 / (ticks - 1)) * (ticks - 1))
      arr = dataset.filter((d) -> d.graphType==2)
      maxValue = d3.max(arr, (item) -> d3.max item.values) || 50
      y2Max = Math.max(100, Math.ceil(maxValue*1.2 / (ticks - 1)) * (ticks - 1))
      y1TickValues = []
      y2TickValues = []
      for i in [0..ticks-1]
        y1TickValues.push i*Math.ceil(y1Max / (ticks - 1))
        y2TickValues.push i*Math.ceil(y2Max / (ticks - 1))
      x = d3.scale.ordinal().domain(days).rangeBands([0, width], 0.4, 0.4)
      miniX = d3.scale.ordinal().domain(days).rangeBands([0, miniWidth], 0, 0)
      y1 = d3.scale.linear().domain([y1Max, 0]).rangeRound([0, height])
      miniY1 = d3.scale.linear().domain([y1Max, 0]).rangeRound([0, miniHeight])
      y2 = d3.scale.linear().domain([y2Max, 0]).rangeRound([0, height])
      miniY2 = d3.scale.linear().domain([y2Max, 0]).rangeRound([0, miniHeight])
      xAxis = d3.svg.axis().scale(x).orient('bottom')
              .outerTickSize(0)
              .innerTickSize(0)
              .tickPadding(10)
      y1Axis = d3.svg.axis().scale(y1).orient('left')
              .innerTickSize(-width)
              .outerTickSize(0)
              .tickValues(y1TickValues)
              .tickFormat (v) -> 
                d = dataset.filter((d) -> d.graphType==1)[0] || {}
                if d.unit == $scope.currency_symbol then $scope.currency_symbol + $filter('number')(v) else $filter('number')(v) + d.unit
      y2Axis = d3.svg.axis().scale(y2).orient('right')
              .innerTickSize(width)
              .outerTickSize(0)
              .tickValues(y2TickValues)
              .tickFormat (v) -> 
                d = dataset.filter((d) -> d.graphType==2)[0] || {}
                if d.unit == $scope.currency_symbol then $scope.currency_symbol + $filter('number')(v) else $filter('number')(v) + d.unit
      mainXZoom = d3.scale.linear()
        .range([0, width])
        .domain([0, width])
      textScale = d3.scale.linear()
        .domain([15,50])
        .range([12,6])
        .clamp(true)
      mainGroup.append('g').attr('class', 'axisX')
        .attr('transform', 'translate(0,' + height + ')')
        .call(xAxis)
        .selectAll("text")  
          .style("text-anchor", "end")
          .attr("dx", "-3.8em")
          .attr("dy", "-10.3em")
          .attr("transform", "rotate(-90)")
      mainGroupWrapper.insert('g', ':first-child').attr('class', 'axisY1').call y1Axis
      mainGroupWrapper.insert('g', ':first-child').attr('class', 'axisY2').call y2Axis
      mainGroup.append('line')
          .style('stroke', '#d9dde0')
          .attr('x1', 0)
          .attr('y1', 0)
          .attr('x2', 0)
          .attr('y2', height + 80)
      mainGroup.append('line')
          .style('stroke', '#d9dde0')
          .attr('x1', width)
          .attr('y1', 0)
          .attr('x2', width)
          .attr('y2', height + 80)
      mainGroup.append('line')
          .style('stroke', '#d9dde0')
          .attr('x1', 0)
          .attr('y1', height)
          .attr('x2', width)
          .attr('y2', height)

      # Brush
      brushExtent = Math.max( 1, Math.min( 30, Math.round(days.length*0.2) ) )
      lastExtent = if days.length <= 30 then miniWidth else miniX(days[brushExtent])

      brush = d3.svg.brush()
          .x(miniX)
          .extent([miniX(days[0]), lastExtent])
          .on("brush", brushmove)

      gBrush = brushGroup.append("g")
        .attr("class", "brush")
        .call(brush)

      gBrush.selectAll(".resize")
        .append("line")
        .attr("y2", miniHeight)

      gBrush.selectAll(".resize")
        .append("path")
        .attr("d", d3.svg.symbol().type("triangle-up").size(20))
        .attr("transform", (d,i) -> 
          if i then "translate(" + -4 + "," + (miniHeight/2) + ") rotate(270)" else "translate(" + 4 + "," + (miniHeight/2) + ") rotate(90)"
        )

      gBrush.selectAll("rect")
        .attr("height", miniHeight)

      gBrush.select(".background")
        .on("mousedown.brush", brushcenter)
        .on("touchstart.brush", brushcenter)

      defs = svg.append("defs")

      defs.append("clipPath")
        .attr("id", svgID.substring(1) + "-clip")
        .append("rect")
        .attr("x", 0)
        .attr("y", 0)
        .attr("width", width)
        .attr("height", height + margin.bottom)

      # Mini graph
      miniGraphLine1 = d3.svg.line()
              .x((value, i) -> miniX(days[i]))
              .y((value, i) -> miniY1(value))
              .defined((value, i) -> _.isNumber value)
      miniGraphLine2 = d3.svg.line()
              .x((value, i) -> miniX(days[i]))
              .y((value, i) -> miniY2(value))
              .defined((value, i) -> _.isNumber value)
      miniGraph = miniGroup.selectAll('.graph')
              .data(dataset)

      miniGraph.enter()
              .append('path')
              .attr 'class', (d) -> 'graph graph-'+d.name.replace(' ', '_')
              .attr 'stroke', (d) -> '#e0e0e0'
              .attr 'd', -> miniGraphLine1(_.map days, -> 0)
              .transition()
              .duration(duration)
              .attr 'd', (d) -> if d.graphType==2 then miniGraphLine2(d.values) else miniGraphLine1(d.values)

      miniGraph.exit()
        .remove()

      gBrush.call(brush.event)

      # Axis titles
      y1TitlePos = () ->
        c = -y1Max.toString().length * 10 - 15
        Math.max(c, 10 - margin.left)
      y2TitlePos = () ->
        c = width + y2Max.toString().length * 10 + 15
        Math.min(c, width + margin.right - 10)
      y1Title = dataset.filter((d) -> d.graphType==1 && !d.hideTitle).map((d) -> d.name).join(' , ')
      y2Title = dataset.filter((d) -> d.graphType==2 && !d.hideTitle).map((d) -> d.name).join(' , ')
      mainGroupWrapper.append('text')
          .attr('text-anchor', 'middle')
          .attr('transform', 'translate(' + y1TitlePos() + ',' + (height/2) + ')rotate(-90)')
          .attr('class', 'title titleY1')
          .text(y1Title)
      mainGroupWrapper.append('text')
          .attr('text-anchor', 'middle')
          .attr('transform', 'translate(' + y2TitlePos() + ',' + (height/2) + ')rotate(90)')
          .attr('class', 'title titleY2')
          .text(y2Title)

      # Graphs
      # graphLine1 = d3.svg.line()
      #         .x((value, i) -> x(days[i]))
      #         .y((value, i) -> y1(value))
      #         .defined((value, i) -> _.isNumber value)
      # graphLine2 = d3.svg.line()
      #         .x((value, i) -> x(days[i]))
      #         .y((value, i) -> y2(value))
      #         .defined((value, i) -> _.isNumber value)
      # graphsContainer = svg.append('g')
      #         .attr('class', 'graphs-container')
      # graphs = graphsContainer.selectAll('.graph')
      #         .data(dataset)
      #         .enter()
      #         .append('path')
      #         .attr('class', (d) -> 'graph graph-'+d.name.replace(' ', '_'))
      #         .attr 'stroke', (d) -> d.color
      #         .attr 'd', -> graphLine1(_.map days, -> 0)
      #         .transition()
      #         .duration(duration)
      #         .attr 'd', (d) -> if d.graphType==2 then graphLine2(d.values) else graphLine1(d.values)

      return if data.length == 0

      # Legends
      legend = mainGroupWrapper.selectAll('g.legend')
          .data(dataset)
          .enter()
          .append('g')
          .attr('class', 'legend')
      legend.append('rect')
          .attr('x', (d, i) -> (width-120*dataset.length)/2 + 120*i)
          .attr('y', height + margin.bottom + miniHeight + miniMargin.top + 20)
          .attr('width', 10)
          .attr('height', 10)
          .style('fill', (d) -> d.color)
      legend.append('text')
          .attr('x', (d, i) -> (width-120*dataset.length)/2 + 120*i + 14)
          .attr('y', height + margin.bottom + miniHeight + miniMargin.top + 30)
          .style('fill', '#2b3c49')
          .on('click', (d) ->
            i = dataset.indexOf(d)
            active = if dataset[i].active then false else true
            newOpacity = if active then 1 else 0
            svg.selectAll('.graph-'+d.name.replace(' ', '_')).attr('visibility', if active then 'visible' else 'hidden')
            if active
              d3.select(this).style('fill', '#2b3c49')
              svg.select('.axisY'+d.graphType).style('opacity', newOpacity)
              svg.select('.titleY'+d.graphType).style('opacity', newOpacity)
            else
              d3.select(this).style('fill', '#7B7B7B')
              activeGraphs = _.filter(dataset, (g) -> g.graphType == d.graphType && g.active)
              if activeGraphs.length == 1 
                svg.select('.axisY'+d.graphType).style('opacity', newOpacity)
                svg.select('.titleY'+d.graphType).style('opacity', newOpacity)
            dataset[i].active = active
          )
          .style("cursor", "pointer")
          .text((d) -> d.name)

    $scope.showNewPmpItemModal = () ->
      modalInstance = $modal.open
        templateUrl: 'modals/pmp_new_item_form.html'
        size: 'md'
        controller: 'PmpNewItemController'
        backdrop: 'static'
        keyboard: false
        resolve:
          item: () -> null
          pmpId: () -> $scope.currentPMP.id
      modalInstance.result.then (pmp_item) ->
        $scope.currentPMP.pmp_items.push pmp_item
        $scope.currentPMP.budget = parseFloat($scope.currentPMP.budget || 0) + parseFloat(pmp_item.budget)
        $scope.currentPMP.budget_loc = parseFloat($scope.currentPMP.budget_loc || 0) + parseFloat(pmp_item.budget_loc)
        $scope.currentPMP.budget_delivered = parseFloat($scope.currentPMP.budget_delivered || 0) + parseFloat(pmp_item.budget_delivered)
        $scope.currentPMP.budget_delivered_loc = parseFloat($scope.currentPMP.budget_delivered_loc || 0) + parseFloat(pmp_item.budget_delivered_loc)
        $scope.currentPMP.budget_remaining = parseFloat($scope.currentPMP.budget_remaining || 0) + parseFloat(pmp_item.budget_remaining)
        $scope.currentPMP.budget_remaining_loc = parseFloat($scope.currentPMP.budget_remaining_loc || 0) + parseFloat(pmp_item.budget_remaining_loc)

    $scope.showPmpEditModal = () ->
      modalInstance = $modal.open
        templateUrl: 'modals/pmp_form.html'
        size: 'md'
        controller: 'PmpsNewController'
        backdrop: 'static'
        keyboard: false
        resolve:
          pmp: () -> $scope.currentPMP
      modalInstance.result.then (pmp) ->
        $scope.currentPMP = pmp

    $scope.deletePmp = () ->
      $scope.errors = {}
      if confirm('Are you sure you want to delete "' +  $scope.currentPMP.name + '"?')
        PMP.delete($scope.currentPMP).then(
          () ->
            $location.path('/revenue').search('filter', 'pmp')
          (resp) ->
            for key, error of resp.data.errors
              $scope.errors[key] = error && error[0]
        )

    $scope.showPmpItemEditModal = (item) ->
      modalInstance = $modal.open
        templateUrl: 'modals/pmp_new_item_form.html'
        size: 'md'
        controller: 'PmpNewItemController'
        backdrop: 'static'
        keyboard: false
        resolve:
          item: () -> angular.copy(item)
          pmpId: () -> $scope.currentPMP.id
      modalInstance.result.then (pmp) ->
        $scope.currentPMP = pmp
        reloadDailyActuals()

    $scope.deletePmpItem = (item) ->
      $scope.errors = {}
      if confirm('Are you sure you want to delete this item?')
        PMPItem.delete(pmp_id: $scope.currentPMP.id, id: item.id).then(
          () ->
            reloadPMPAndCharts(item.id)
            reloadDailyActuals()
          (resp) ->
            for key, error of resp.data.errors
              $scope.errors[key] = error && error[0]
        )      

    $scope.showDailyActualEditModal = (pmpItemDailyActual) ->
      modalInstance = $modal.open
        templateUrl: 'modals/pmp_item_new_daily_actual_form.html'
        size: 'md'
        controller: 'PmpItemNewDailyActualController'
        backdrop: 'static'
        keyboard: false
        resolve:
          dailyActual: () -> angular.copy(pmpItemDailyActual)
          pmpId: () -> $scope.currentPMP.id
          pmpItems: () -> $scope.currentPMP.pmp_items
      modalInstance.result.then (data) ->
        index = $scope.pmpItemDailyActuals.indexOf(pmpItemDailyActual)
        $scope.pmpItemDailyActuals[index] = data
        reloadPMPAndCharts(pmpItemDailyActual.pmp_item_id)

    $scope.deleteDailyActual = (dailyActual) ->
      $scope.errors = {}
      if confirm('Are you sure you want to delete this item?')
        PMPItemDailyActual.delete(pmp_id: $scope.currentPMP.id, id: dailyActual.id).then(
          () ->
            $scope.pmpItemDailyActuals = _.without($scope.pmpItemDailyActuals, dailyActual) || []
            reloadPMPAndCharts(dailyActual.pmp_item_id)
          (resp) ->
            for key, error of resp.data.errors
              $scope.errors[key] = error && error[0]
        )   

    reloadPMPAndCharts = (pmpItemId) ->
      PMP.get($routeParams.id).then (pmp) ->
        $scope.currentPMP = pmp
        updateChartsByPmpItemId(pmpItemId)

    updateChartsByPmpItemId = (id) ->
      if $scope.selectedDeliveryItem.id == id || $scope.selectedPriceItem.id == id
        pmpItem = $scope.currentPMP.pmp_items.filter((d) -> d.id == id)[0] || $scope.currentPMP.pmp_items[0]
        graphData[id] = null
        $scope.updateDeliveryChart(pmpItem) if $scope.selectedDeliveryItem.id == id
        $scope.updatePriceChart(pmpItem) if $scope.selectedPriceItem.id == id
      if $scope.selectedPriceItem == 'all' || $scope.selectedDeliveryItem == 'all'
        graphData['all'] = null
        $scope.updateDeliveryChart('all') if $scope.selectedDeliveryItem == 'all'
        $scope.updatePriceChart('all') if $scope.selectedPriceItem == 'all'
    
    init()
  ]
