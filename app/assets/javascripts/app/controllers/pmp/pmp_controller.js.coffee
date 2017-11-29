@app.controller 'PMPController',
  ['$rootScope', '$scope', '$modal', '$filter', '$timeout', '$routeParams', '$window', '$q', 'PMP', 'PMPMember', 'SSP', 'User', 'CurrentUser', 'Company'
  ( $rootScope,   $scope,   $modal,   $filter,   $timeout,   $routeParams,   $window,   $q,   PMP,   PMPMember,   SSP,   User,   CurrentUser,   Company) ->
      $scope.currentPMP = {}
      $scope.currency_symbol = '$'
      $scope.canEditIO = true
      $scope.selectedItem = {}
      $scope.selectedPriceItem = {}
      $scope.pmpItemDailyActuals = []
      $scope.isLoading = false
      $scope.allDataLoaded = false
      $scope.page = 1
      graphData = {}
      
      $scope.init = ->
        CurrentUser.get().$promise.then (user) ->
          $scope.currentUser = user
        Company.get().$promise.then (company) ->
          $scope.company = company
          $scope.canEditIO = $scope.company.io_permission[$scope.currentUser.user_type]
        SSP.all().then (ssps) ->
          $scope.ssps = ssps
        PMP.get($routeParams.id).then (pmp) ->
          $scope.currentPMP = pmp
          console.log(pmp)
          if pmp.currency
            if pmp.currency.curr_symbol
              $scope.currency_symbol = pmp.currency.curr_symbol
          
          PMP.pmp_item_daily_actuals($routeParams.id).then (data) ->
            $scope.pmpItemDailyActuals = data
          
          $scope.updateChart($scope.currentPMP.pmp_items[0])
          $scope.updatePriceChart($scope.currentPMP.pmp_items[0])

          $scope.currency_symbol = (->
            if $scope.currentPMP && $scope.currentPMP.currency
              if $scope.currentPMP.currency.curr_symbol
                return $scope.currentPMP.currency.curr_symbol
              else if $scope.currentPMP.currency.curr_cd
                return $scope.currentPMP.currency.curr_cd
            return '%'
          )()

      $scope.loadMoreData = ->
        $scope.isLoading = true
        PMP.pmp_item_daily_actuals($routeParams.id, {page: ++$scope.page}).then (data) ->
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

      $scope.updateChart = (pmpItem) ->
        if pmpItem
          $scope.selectedItem = pmpItem
          if graphData[pmpItem.id]
            drawChart(graphData[pmpItem.id], '#pmp-delivery-chart-container', '#pmp-delivery-chart')
          else
            PMP.pmp_item_daily_actuals($routeParams.id, {pmp_item_id: pmpItem.id}).then (data) ->
              graphData[pmpItem.id] = data
              drawChart(data, '#pmp-delivery-chart-container', '#pmp-delivery-chart')

      $scope.updatePriceChart = (pmpItem) ->
        if pmpItem
          $scope.selectedPriceItem = pmpItem
          if graphData[pmpItem.id]
            drawChart(graphData[pmpItem.id], '#pmp-price-revenue-chart-container', '#pmp-price-revenue-chart')
          else
            PMP.pmp_item_daily_actuals($routeParams.id, {pmp_item_id: pmpItem.id}).then (data) ->
              graphData[pmpItem.id] = data
              drawChart(data, '#pmp-price-revenue-chart-container', '#pmp-price-revenue-chart')

      getGraphDataSet = (data, svgID) ->
        c = d3.scale.category10()
        switch svgID
          when '#pmp-delivery-chart'
            [
              {name: 'Bids', graphType: 1, active: true, unit: '', color: c(0), values: data.map((item) -> parseFloat(item.bids))}
              {name: 'Impressions', graphType: 1, active: true, unit: '', color: c(1), values: data.map((item) -> parseFloat(item.impressions))}          
              {name: 'Win Rate', graphType: 2, active: true, unit: '%', color: c(2), values: data.map((item) -> parseFloat(item.win_rate))}
            ]
          when '#pmp-price-revenue-chart'
            [
              {name: 'Price', graphType: 1, active: true, unit: '$', color: c(0), values: data.map((item) -> parseFloat(item.price))}
              {name: 'Revenue', graphType: 2, active: true, unit: '$', color: c(1), values: data.map((item) -> parseFloat(item.revenue))}          
            ]
          else []

      drawChart = (data, containerID, svgID) ->
        chartContainer = angular.element(containerID)
        margin =
            top: 65
            left: 65
            right: 65
            bottom: 90
        duration = 1000
        ratio = 0.35
        ticks = 11
        width = chartContainer.width() - margin.left - margin.right || 800
        height = chartContainer.width()*ratio
        data = data.sort (a,b) -> new Date(a.date) - new Date(b.date)
        days = data.map((item) -> item.date)
        dataset = getGraphDataSet(data, svgID)
        return if dataset.length == 0 
        svg = d3.select(svgID)
                .attr("preserveAspectRatio", "xMinYMin meet")
                .attr("viewBox", "0 0 " + (width + margin.left + margin.right) + " " + height)
                .html('')
                .append('g')
                .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
        height = height - margin.top - margin.bottom - 10

        # Axes
        y1Max = y2Max = 100
        if svgID == '#pmp-delivery-chart'
          maxData = d3.max [dataset[0],dataset[1]], (item) -> d3.max item.values
          y1Max = Math.ceil(maxData*1.2 / (ticks - 1)) * (ticks - 1)
          y2Max = 100
        else
          maxData = d3.max [dataset[0]], (item) -> d3.max item.values
          y1Max = Math.ceil(maxData*1.2 / (ticks - 1)) * (ticks - 1)
          maxData = d3.max [dataset[1]], (item) -> d3.max item.values
          y2Max = Math.ceil(maxData*1.2 / (ticks - 1)) * (ticks - 1)
        y1TickValues = []
        y2TickValues = []
        for i in [0..ticks-1]
          y1TickValues.push i*Math.ceil(y1Max / (ticks - 1))
          y2TickValues.push i*Math.ceil(y2Max / (ticks - 1))
        x = d3.scale.ordinal().domain(days).rangePoints([20, width-20])
        y1 = d3.scale.linear().domain([y1Max, 0]).rangeRound([0, height])
        y2 = d3.scale.linear().domain([y2Max, 0]).rangeRound([0, height])
        xAxis = d3.svg.axis().scale(x).orient('bottom')
                .outerTickSize(0)
                .innerTickSize(0)
                .tickPadding(10)
        y1Axis = d3.svg.axis().scale(y1).orient('left')
                .innerTickSize(-width)
                .outerTickSize(0)
                .tickValues(y1TickValues)
                .tickFormat (v) -> if dataset[0].unit == '$' then '$' + v else v + dataset[0].unit
        y2Axis = d3.svg.axis().scale(y2).orient('right')
                .innerTickSize(width)
                .outerTickSize(0)
                .tickValues(y2TickValues)
                .tickFormat (v) -> if dataset[dataset.length-1].unit == '$' then '$' + v else v + dataset[dataset.length-1].unit
        svg.append('g').attr('class', 'axisX')
          .attr('transform', 'translate(0,' + height + ')')
          .call(xAxis)
          .selectAll("text")  
            .style("text-anchor", "end")
            .attr("dx", "-.8em")
            .attr("dy", "-.3em")
            .attr("transform", "rotate(-90)" )
        svg.append('g').attr('class', 'axisY1').call y1Axis
        svg.append('g').attr('class', 'axisY2').call y2Axis

        # Graphs
        graphLine1 = d3.svg.line()
                .x((value, i) -> x(days[i]))
                .y((value, i) -> y1(value))
                .defined((value, i) -> _.isNumber value)
        graphLine2 = d3.svg.line()
                .x((value, i) -> x(days[i]))
                .y((value, i) -> y2(value))
                .defined((value, i) -> _.isNumber value)
        graphsContainer = svg.append('g')
                .attr('class', 'graphs-container')
        graphs = graphsContainer.selectAll('.graph')
                .data(dataset)
                .enter()
                .append('path')
                .attr('class', (d) -> 'graph graph-'+d.name.replace(' ', '_'))
                .attr 'stroke', (d) -> d.color
                .attr 'd', -> graphLine1(_.map days, -> 0)
                .transition()
                .duration(duration)
                .attr 'd', (d) -> if d.graphType==2 then graphLine2(d.values) else graphLine1(d.values)

        # Legends
        legend = svg.selectAll('g.legend')
            .data(dataset)
            .enter()
            .append('g')
            .attr('class', 'legend')
        legend.append('rect')
            .attr('x', width - margin.right - 50)
            .attr('y', (d, i) -> 20*i - 60)
            .attr('width', 10)
            .attr('height', 10)
            .style('fill', (d) -> d.color)
        legend.append('text')
            .attr('x', width - margin.right - 36)
            .attr('y', (d, i) -> 10 + 20*i - 60)
            .style('fill', '#2b3c49')
            .on('click', (d) ->
              i = dataset.indexOf(d)
              active = if dataset[i].active then false else true
              newOpacity = if active then 1 else 0
              svg.selectAll('.graph-'+d.name.replace(' ', '_')).style('opacity', newOpacity)
              if active
                d3.select(this).style('fill', '#2b3c49')
                svg.select('.axisY'+d.graphType).style('opacity', newOpacity)
              else
                d3.select(this).style('fill', '#7B7B7B')
                activeGraphs = _.filter(dataset, (g) -> g.graphType == d.graphType && g.active)
                if activeGraphs.length == 1 
                  svg.select('.axisY'+d.graphType).style('opacity', newOpacity)
              dataset[i].active = active
            )
            .style("cursor", "pointer")
            .text((d) -> d.name)

        # Tooltip
        tooltip = d3.select("body").append("div") 
            .attr("class", "pmp-chart-tooltip")             
            .style("opacity", 0)
        mouseOut = (d) ->
          d3.select(this).transition().duration(500).attr("r", 4)   
          tooltip.transition()        
              .duration(500)      
              .style("opacity", 0);
        mouseOver = (title, unit) ->
          return (d) ->
            d3.select(this).transition().duration(500).attr("r", 6)     
            tooltip.transition()        
                .duration(200)      
                .style("opacity", .9);      
            tooltip.html('<p>' + $scope.selectedItem.ssp_deal_id + '</p><p><span>' + (if unit == '$' then '$' + d else d + unit) + '</span></p><p><span>' + title + '</span></p>')  
                .style("left", (d3.event.pageX) - 50 + "px")     
                .style("top", (d3.event.pageY + 18) + "px")
        setTimeout ->
          for d in dataset            
            svg.selectAll("circle.graph-" + d.name)    
                .data(d.values)         
                .enter()
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
        , duration

      $scope.init()
  ]
