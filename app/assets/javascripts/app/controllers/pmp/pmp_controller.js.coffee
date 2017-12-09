@app.controller 'PMPController',
  ['$rootScope', '$scope', '$modal', '$location', '$filter', '$timeout', '$routeParams', 'PMP', 'PMPMember', 'User', 'PMPItem', 'PMPItemDailyActual',
  ( $rootScope,   $scope,   $modal,   $location,   $filter,   $timeout,   $routeParams,   PMP,   PMPMember,   User,   PMPItem,   PMPItemDailyActual) ->
    $scope.currentPMP = {}
    $scope.currency_symbol = '$'
    $scope.selectedDeliveryItem = {}
    $scope.selectedPriceItem = {}
    $scope.pmpItemDailyActuals = []
    $scope.isLoading = false
    $scope.allDataLoaded = false
    $scope.page = 1
    graphData = {}
    
    init = () ->
      PMP.get($routeParams.id).then (pmp) ->
        $scope.currentPMP = pmp
        $scope.updateDeliveryChart('all')
        $scope.updatePriceChart('all')
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
        id = if pmpItem == 'all' then 'all' else pmpItem.id
        if graphData[id]
          drawChart(graphData[id], '#pmp-delivery-chart-container', '#pmp-delivery-chart')
        else
          PMPItemDailyActual.all(pmp_id: $routeParams.id, pmp_item_id: id).then (data) ->
            graphData[id] = data
            drawChart(data, '#pmp-delivery-chart-container', '#pmp-delivery-chart')

    $scope.updatePriceChart = (pmpItem) ->
      if pmpItem
        $scope.selectedPriceItem = pmpItem
        id = if pmpItem == 'all' then 'all' else pmpItem.id
        if graphData[id]
          drawChart(graphData[id], '#pmp-price-revenue-chart-container', '#pmp-price-revenue-chart')
        else
          PMPItemDailyActual.all(pmp_id: $routeParams.id, pmp_item_id: id).then (data) ->
            graphData[id] = data
            drawChart(data, '#pmp-price-revenue-chart-container', '#pmp-price-revenue-chart')

    getGraphDataSet = (data, svgID) ->
      c = d3.scale.category10()
      switch svgID
        when '#pmp-delivery-chart'
          [
            {name: 'Bids', graphType: 1, hideTitle: true, active: true, unit: '', color: c(0), values: data.map((item) -> parseFloat(item.bids))}
            {name: 'Win Rate', graphType: 2, active: true, unit: '%', color: c(2), values: data.map((item) -> parseFloat(item.win_rate))}
            {name: 'Impressions', graphType: 1, active: true, unit: '', color: c(1), values: data.map((item) -> parseFloat(item.impressions))}          
          ]
        when '#pmp-price-revenue-chart'
          [
            {name: 'Price', graphType: 1, active: true, unit: $scope.currency_symbol, color: c(0), values: data.map((item) -> parseFloat(item.price))}
            {name: 'Revenue', graphType: 2, active: true, unit: $scope.currency_symbol, color: c(1), values: data.map((item) -> parseFloat(item.revenue_loc))}          
          ]
        else []

    drawChart = (data, containerID, svgID) ->
      # return if data.length == 0
      chartContainer = angular.element(containerID)
      margin =
          top: 35
          left: 85
          right: 85
          bottom: 115
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
      svg.append('line')
          .style('stroke', '#d9dde0')
          .attr('x1', 0)
          .attr('y1', 0)
          .attr('x2', 0)
          .attr('y2', height + 80)
      svg.append('line')
          .style('stroke', '#d9dde0')
          .attr('x1', width)
          .attr('y1', 0)
          .attr('x2', width)
          .attr('y2', height + 80)
      svg.append('line')
          .style('stroke', '#d9dde0')
          .attr('x1', 0)
          .attr('y1', height)
          .attr('x2', width)
          .attr('y2', height)

      # Axis titles
      y1TitlePos = () ->
        c = -y1Max.toString().length * 10 - 15
        Math.max(c, 10 - margin.left)
      y2TitlePos = () ->
        c = width + y2Max.toString().length * 10 + 15
        Math.min(c, width + margin.right - 10)
      y1Title = dataset.filter((d) -> d.graphType==1 && !d.hideTitle).map((d) -> d.name).join(' , ')
      y2Title = dataset.filter((d) -> d.graphType==2 && !d.hideTitle).map((d) -> d.name).join(' , ')
      svg.append('text')
          .attr('text-anchor', 'middle')
          .attr('transform', 'translate(' + y1TitlePos() + ',' + (height/2) + ')rotate(-90)')
          .attr('class', 'title titleY1')
          .text(y1Title)
      svg.append('text')
          .attr('text-anchor', 'middle')
          .attr('transform', 'translate(' + y2TitlePos() + ',' + (height/2) + ')rotate(90)')
          .attr('class', 'title titleY2')
          .text(y2Title)

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

      return if data.length == 0

      # Legends
      legend = svg.selectAll('g.legend')
          .data(dataset)
          .enter()
          .append('g')
          .attr('class', 'legend')
      legend.append('rect')
          .attr('x', (d, i) -> (width-120*dataset.length)/2 + 120*i)
          .attr('y', height + 100)
          .attr('width', 10)
          .attr('height', 10)
          .style('fill', (d) -> d.color)
      legend.append('text')
          .attr('x', (d, i) -> (width-120*dataset.length)/2 + 120*i + 14)
          .attr('y', height + 110)
          .style('fill', '#2b3c49')
          .on('click', (d) ->
            i = dataset.indexOf(d)
            active = if dataset[i].active then false else true
            newOpacity = if active then 1 else 0
            svg.selectAll('.graph-'+d.name.replace(' ', '_')).style('opacity', newOpacity)
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
        selectedItem = if svgID == '#pmp-delivery-chart' then $scope.selectedDeliveryItem else $scope.selectedPriceItem
        return (d) ->
          d3.select(this).transition().duration(500).attr("r", 6)     
          tooltip.transition()        
              .duration(200)      
              .style("opacity", .9);      
          tooltip.html('<p>' + (selectedItem.ssp_deal_id || $filter('firstUppercase')(selectedItem)) + '</p><p><span>' + (if unit == $scope.currency_symbol then unit + $filter('number')(d) else $filter('number')(d) + unit) + '</span></p><p><span>' + title + '</span></p>')  
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
            $scope.currentPMP.pmp_items = _.without($scope.currentPMP.pmp_items, item) || []
            updateChartsByPmpItemId(item.id)
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
