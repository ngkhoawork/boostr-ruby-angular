@app.controller 'PMPController',
  ['$rootScope', '$scope', '$modal', '$filter', '$timeout', '$routeParams', '$window', '$q', 'PMP', 'PMPMember', 'SSP', 'User', 'CurrentUser', 'Company'
  ( $rootScope,   $scope,   $modal,   $filter,   $timeout,   $routeParams,   $window,   $q,   PMP,   PMPMember,   SSP,   User,   CurrentUser,   Company) ->
      $scope.currentPMP = {}
      $scope.currency_symbol = '$'
      $scope.canEditIO = true
      $scope.selectedItem = {}
      $scope.pmpItemDailyActuals = []
      
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
          if pmp.currency
            if pmp.currency.curr_symbol
              $scope.currency_symbol = pmp.currency.curr_symbol
          PMP.pmp_item_daily_actuals($routeParams.id).then (data) ->
            $scope.pmpItemDailyActuals = data
            $scope.updateChart($scope.currentPMP.pmp_items[0])

          $scope.currency_symbol = (->
            if $scope.currentPMP && $scope.currentPMP.currency
              if $scope.currentPMP.currency.curr_symbol
                return $scope.currentPMP.currency.curr_symbol
              else if $scope.currentPMP.currency.curr_cd
                return $scope.currentPMP.currency.curr_cd
            return '%'
          )()

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
          drawChart($scope.pmpItemDailyActuals.filter((item) -> item.pmp_item_id == pmpItem.id))

      drawChart = (data) ->
        chartContainer = angular.element('#pmp-delivery-chart-container')
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
        c = d3.scale.category10()
        data = data.sort (a,b) -> new Date(a.date) - new Date(b.date)
        days = data.map((item) -> item.date)
        dataset = [
          {name: 'Bids', color: c(0), values: data.map((item) -> parseFloat(item.bids))}
          {name: 'Impressions', color: c(1), values: data.map((item) -> parseFloat(item.impressions))}          
          {name: 'Win Rate', color: c(2), values: data.map((item) -> parseFloat(item.win_rate))}
        ]

        svg = d3.select('#pmp-delivery-chart')
                .attr("preserveAspectRatio", "xMinYMin meet")
                .attr("viewBox", "0 0 " + (width + margin.left + margin.right) + " " + height)
                .html('')
                .append('g')
                .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
        height = height - margin.top - margin.bottom - 10

        maxValue = (d3.max [dataset[0],dataset[1]], (item) -> d3.max item.values) || 100
        y1Max = Math.ceil(maxValue / (ticks - 1) / 10) * 10 * (ticks - 1)
        tickValues = []
        for i in [0..ticks-1]
          tickValues.push i*Math.ceil(maxValue / (ticks - 1) / 10)*10
        console.log(tickValues);
        x = d3.scale.ordinal().domain(days).rangePoints([20, width-20])
        y1 = d3.scale.linear().domain([y1Max, 0]).rangeRound([0, height])
        y2 = d3.scale.linear().domain([100, 0]).rangeRound([0, height])

        xAxis = d3.svg.axis().scale(x).orient('bottom')
                .outerTickSize(0)
                .innerTickSize(0)
                .tickPadding(10)
        y1Axis = d3.svg.axis().scale(y1).orient('left')
                .innerTickSize(0)
                .tickPadding(10)
                .outerTickSize(0)
                .tickValues(tickValues)
        y2Axis = d3.svg.axis().scale(y2).orient('right')
                .innerTickSize(width)
                .tickPadding(10)
                .outerTickSize(0)
                .ticks(ticks)
                .tickFormat (v) -> v + '%'

        svg.append('g').attr('class', 'axisX')
          .attr('transform', 'translate(0,' + height + ')')
          .call(xAxis)
          .selectAll("text")  
            .style("text-anchor", "end")
            .attr("dx", "-.8em")
            .attr("dy", "-.3em")
            .attr("transform", "rotate(-90)" )
        svg.append('g').attr('class', 'axisY').call y1Axis
        svg.append('g').attr('class', 'axisY').call y2Axis

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
                .attr('class', 'graph')
                .attr 'stroke', (d) -> d.color
                .attr 'd', -> graphLine1(_.map days, -> 0)
                .transition()
                .duration(duration)
                .attr 'd', (d) -> if d.name=='Win Rate' then graphLine2(d.values) else graphLine1(d.values)

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
            .text((d) -> d.name)

        tooltip = d3.select("body").append("div") 
            .attr("class", "pmp-delivery-tooltip")             
            .style("opacity", 1)
        mouseOut = (d) ->
          d3.select(this).transition().duration(500).attr("r", 4)   
          tooltip.transition()        
              .duration(500)      
              .style("opacity", 0);
        mouseOver = (title, option, unit) ->
          return (d) ->
            d3.select(this).transition().duration(500).attr("r", 6)     
            tooltip.transition()        
                .duration(200)      
                .style("opacity", .9);      
            tooltip.html('<p>' + $scope.selectedItem.ssp_deal_id + '</p><p><span>' + d[option] + (unit || '') + '</span></p><p><span>' + title + '</span></p>')  
                .style("left", (d3.event.pageX) - 50 + "px")     
                .style("top", (d3.event.pageY + 18) + "px")
        setTimeout ->
          svg.selectAll("dot")    
              .data(data)         
              .enter().append("circle") 
              .style("cursor", "pointer")  
              .attr("fill", c(0))                              
              .attr("r", 4)       
              .attr("cx", (d) -> x(d.date))       
              .attr("cy", (d) -> y1(d.bids))     
              .on("mouseover", mouseOver('Bids', 'bids'))                  
              .on("mouseout", mouseOut)
              .style("opacity", 0)
              .transition()
              .duration(500)
              .style("opacity", 1)
          svg.selectAll("dot")    
              .data(data)         
              .enter().append("circle") 
              .style("cursor", "pointer")
              .attr("fill", c(1))                              
              .attr("r", 4)       
              .attr("cx", (d) -> x(d.date))       
              .attr("cy", (d) -> y1(d.impressions))     
              .on("mouseover", mouseOver('Impressions', 'impressions'))                  
              .on("mouseout", mouseOut)
              .style("opacity", 0)
              .transition()
              .duration(500)
              .style("opacity", 1)
          svg.selectAll("dot")    
              .data(data)         
              .enter().append("circle") 
              .style("cursor", "pointer")
              .attr("fill", c(2))                                      
              .attr("r", 4)       
              .attr("cx", (d) -> x(d.date))       
              .attr("cy", (d) -> y2(d.win_rate))     
              .on("mouseover", mouseOver('Win Rate', 'win_rate', '%'))                  
              .on("mouseout", mouseOut)
              .style("opacity", 0)
              .transition()
              .duration(500)
              .style("opacity", 1)
        , duration

      $scope.init()
  ]
