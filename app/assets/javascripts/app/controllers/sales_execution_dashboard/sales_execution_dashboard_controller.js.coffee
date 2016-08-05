@app.controller 'SalesExecutionDashboardController',
  ['$rootScope', '$scope', '$q', 'Team', 'SalesExecutionDashboard', 'SalesExecutionDashboardDataStore'
    ($rootScope, $scope, $q, Team, SalesExecutionDashboard, SalesExecutionDashboardDataStore) ->

      $scope.isDisabled = false
      $scope.selectedMember = null
      $scope.selectedTeamId = null
      $scope.selectedMemberId = null
      $scope.productPipelineChoice = 'weighted'
      $scope.optionsProductPipeline = SalesExecutionDashboardDataStore.getOptionsProductPipeline()

      $scope.init = () =>
        Team.all(all_teams: true).then (teams) ->
          all_members = []
          _.each teams, (team) ->
            all_members = all_members.concat(team.members)
#          $scope.teams = teams
          $scope.teams = [{
            id: 0,
            name:'All Teams',
            children: teams,
            members: all_members,
            members_count: all_members.length
          }]
          $scope.selectedTeam = $scope.teams[0]
          $scope.selectedTeamId = $scope.selectedTeam.id

          data = calculateKPIsForTeam($scope.teams[0])
          $scope.allAverageWinRate = data.averageWinRate
          $scope.allAverageCycleTime = data.averageCycleTime
          $scope.allAverageDealSize = data.averageDealSize



      updateProductPipelineData = () =>
        if ($scope.productPipelineChoice == "weighted")
          $scope.dataProductPipeline = $scope.productPipelineData.weighted
        else
          $scope.dataProductPipeline = $scope.productPipelineData.unweighted

      calculateKPIs = () =>
        $scope.averageWinRate = 0
        $scope.averageCycleTime = 0
        $scope.averageDealSize = 0

        if ($scope.selectedMember == null && $scope.selectedTeam && $scope.selectedTeam.members.length > 0)
          data = calculateKPIsForTeam($scope.selectedTeam)
          $scope.averageWinRate = data.averageWinRate
          $scope.averageCycleTime = data.averageCycleTime
          $scope.averageDealSize = data.averageDealSize
        else if ($scope.selectedMember)
          calculateKPIsForMember()

        SalesExecutionDashboard.all("member_ids[]": $scope.selectedMemberList, team_id: $scope.selectedTeamId, member_id: $scope.selectedMemberId).then (data) ->
          $scope.topDeals = data[0].top_deals
          maxValue = data[0].week_pipeline_data
          maxValue = _.max(_.map data[0].week_pipeline_data, (item) =>
            return item.value
          )

          $scope.chartWeekPipeMovement = _.map data[0].week_pipeline_data, (item) =>
            item.styles = {'width': ( if maxValue > 0 then item.value / maxValue * 100 else 0) + "%", 'background-color': item.color}
            return item

          $scope.productPipelineData = data[0].product_pipeline_data
          updateProductPipelineData()
        SalesExecutionDashboard.forecast(team_id: $scope.selectedTeamId, member_id: $scope.selectedMemberId).then (data) ->
          SalesExecutionDashboardDataStore.setDataQuarterForecast(data);
          $scope.dataQuaterForecast =  SalesExecutionDashboardDataStore.getGraphDataQuarterForecast()
          $scope.optionsQuarterForecast = SalesExecutionDashboardDataStore.getOptionsQuarterForecast()


      calculateKPIsForTeam = (team) =>
        if team.members.length > 0
          win_rate_count = 0
          cycle_time_count = 0
          deal_size_count = 0
          averageWinRate = 0
          averageCycleTime = 0
          averageDealSize = 0

          _.each team.members, (item) =>
            if (item.win_rate > 0)
              averageWinRate = averageWinRate + parseFloat(item.win_rate)
              win_rate_count = win_rate_count + 1

            if (item.cycle_time > 0)
              averageCycleTime = averageCycleTime + parseFloat(item.cycle_time)
              cycle_time_count = cycle_time_count + 1

            if (item.average_deal_size > 0)
              averageDealSize = averageDealSize + parseFloat(item.average_deal_size)
              deal_size_count = deal_size_count + 1

          if win_rate_count > 0
            averageWinRate = Number((averageWinRate / win_rate_count * 100).toFixed(0))
          if cycle_time_count > 0
            averageCycleTime = Number((averageCycleTime / cycle_time_count).toFixed(0))
          if deal_size_count > 0
            averageDealSize = Number((averageDealSize / deal_size_count / 1000).toFixed(0))

          return {averageWinRate: averageWinRate, averageCycleTime: averageCycleTime, averageDealSize: averageDealSize}

      calculateKPIsForMember = () =>
        if $scope.selectedMember
          $scope.averageWinRate = (if ($scope.selectedMember.win_rate > 0) then Number(($scope.selectedMember.win_rate * 100).toFixed(0)) else 0)
          $scope.averageCycleTime = (if ($scope.selectedMember.cycle_time > 0) then Number(($scope.selectedMember.cycle_time).toFixed(0)) else 0)
          $scope.averageDealSize = (if ($scope.selectedMember.average_deal_size > 0) then Number(($scope.selectedMember.average_deal_size / 1000).toFixed(0)) else 0)

      $scope.$watch('selectedTeam', () =>
        if ($scope.selectedTeam)
          $scope.selectedTeamId = $scope.selectedTeam.id
          $scope.selectedMember = null
          $scope.selectedMemberId = null
          $scope.selectedMemberList = _.map $scope.selectedTeam.members, (item) =>
            return item.id
          calculateKPIs()
      , true);

      $scope.changeMember=(value) =>
        $scope.selectedMember = value
        $scope.selectedMemberId = $scope.selectedMember.id
        $scope.selectedMemberList = [$scope.selectedMember.id]
        calculateKPIs()

      $scope.changeProductPipelineChoice=(value) =>
        $scope.productPipelineChoice = value
        updateProductPipelineData()

      $rootScope.$on 'quarterForecastRendered1', (index) ->
        container = d3.select(".quarter-forecast-chart1")
        svg = container.select("svg")
        nvGroups = svg.selectAll("g.nv-groups")
        rects = nvGroups.selectAll("rect.nv-bar")
        width = rects[0][0].width.baseVal.value

        defRect = svg.selectAll("defs").selectAll("rect")
        y = defRect[0][0].height.baseVal.value * ($scope.dataQuaterForecast[0].maxValue - $scope.dataQuaterForecast[0].quota) / $scope.dataQuaterForecast[0].maxValue

        newGroup = nvGroups.selectAll('g.nv-series-6')

        if newGroup.length > 0
          newGroup.remove()
        newGroup = nvGroups.append('g')
          .attr('class', 'nv-group nv-series-6')
          .style('stroke-opacity', 1)

        newGroup.append("line")
          .attr("x1", 0)
          .attr("y1", y)
          .attr("x2", width)
          .attr("y2", y)
          .attr("stroke-width", 3)
          .style("stroke-dasharray", ("3, 3"))
          .attr("transform", 'translate(' + width + ', 0)')
          .attr("stroke", "#666b80")
      $rootScope.$on 'quarterForecastRendered2', (index) ->
        container = d3.select(".quarter-forecast-chart2")
        svg = container.select("svg")
        nvGroups = svg.selectAll("g.nv-groups")
        rects = nvGroups.selectAll("rect.nv-bar")
        width = rects[0][0].width.baseVal.value

        defRect = svg.selectAll("defs").selectAll("rect")
        y = defRect[0][0].height.baseVal.value * ($scope.dataQuaterForecast[1].maxValue - $scope.dataQuaterForecast[1].quota) / $scope.dataQuaterForecast[1].maxValue

        newGroup = nvGroups.selectAll('g.nv-series-6')

        if newGroup.length > 0
          newGroup.remove()
        newGroup = nvGroups.append('g')
        .attr('class', 'nv-group nv-series-6')
        .style('stroke-opacity', 1)

        newGroup.append("line")
        .attr("x1", 0)
        .attr("y1", y)
        .attr("x2", width)
        .attr("y2", y)
        .attr("stroke-width", 3)
        .style("stroke-dasharray", ("3, 3"))
        .attr("transform", 'translate(' + width + ', 0)')
        .attr("stroke", "#666b80")


      $scope.init()
  ]
