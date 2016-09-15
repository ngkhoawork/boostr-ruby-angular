@app.controller 'SalesExecutionDashboardController',
  ['$rootScope',
   '$scope',
   '$q',
   'Team',
   'SalesExecutionDashboard',
   'SalesExecutionDashboardDataStore',
   'DealLossSummaryDataStore',
   'DealLossStagesDataStore',
   'ActivitySummaryDataStore'
    ($rootScope,
     $scope,
     $q,
     Team,
     SalesExecutionDashboard,
     SalesExecutionDashboardDataStore,
     DealLossSummaryDataStore,
     DealLossStagesDataStore,
     ActivitySummaryDataStore) ->

      $scope.isDisabled = false
      $scope.selectedMember = null
      $scope.selectedTeamId = null
      $scope.selectedMemberId = null

      $scope.productPipelineChoice = 'weighted'
      $scope.optionsProductPipeline = SalesExecutionDashboardDataStore.getOptionsProductPipeline()

      $scope.dealLossSummaryChoice = "qtd"
      $scope.optionsDealLossSummary = DealLossSummaryDataStore.getOptions()

      $scope.dealLossStagesChoice = "qtd"
      $scope.kpisChoice = "qtd"

      $scope.activitySummaryChoice = "qtd"
      $scope.optionsActivitySummary = ActivitySummaryDataStore.getOptions()

      $scope.allMemberId = []
      $scope.allLeaderId = []

      $scope.init = () =>
        Team.all(all_teams: true).then (teams) ->
          all_members = []
          all_leaders = []
          _.each teams, (team) ->
            all_members = all_members.concat(team.members)
            all_leaders = all_leaders.concat(team.leaders)
#          $scope.teams = teams
          $scope.teams = [{
            id: 0,
            name:'All Teams',
            children: teams,
            members: all_members,
            leaders: all_leaders,
            members_count: all_members.length
          }]
          $scope.allMemberId = _.map $scope.teams[0].members, (member) ->
            return member.id
          $scope.allLeaderId = _.map $scope.teams[0].leaders, (member) ->
            return member.id
          $scope.selectedTeam = $scope.teams[0]
          $scope.selectedTeamId = $scope.selectedTeam.id

          SalesExecutionDashboard.kpis("member_ids[]": $scope.allMemberId.concat($scope.allLeaderId), time_period: $scope.kpisChoice).then (data) ->
            $scope.allKPIs = data[0]


      updateProductPipelineData = () =>
        if ($scope.productPipelineChoice == "weighted")
          $scope.dataProductPipeline = $scope.productPipelineData.weighted
        else
          $scope.dataProductPipeline = $scope.productPipelineData.unweighted

      calculateKPIs = () =>

        SalesExecutionDashboard.activity_summary("member_ids[]": $scope.selectedMemberList, time_period: $scope.activitySummaryChoice).then (data) ->
          ActivitySummaryDataStore.setData(data)
          $scope.dataActivitySummary = ActivitySummaryDataStore.getData()
          $scope.optionsActivitySummary = ActivitySummaryDataStore.getOptions()

        SalesExecutionDashboard.deal_loss_summary("member_ids[]": $scope.selectedMemberList, time_period: $scope.dealLossSummaryChoice).then (data) ->
          DealLossSummaryDataStore.setData(data)
          $scope.dataDealLossSummary = DealLossSummaryDataStore.getData()
          $scope.optionsDealLossSummary = DealLossSummaryDataStore.getOptions()

        SalesExecutionDashboard.deal_loss_stages("member_ids[]": $scope.selectedMemberList, time_period: $scope.dealLossSummaryChoice).then (data) ->
          DealLossStagesDataStore.setData(data)
          $scope.dataDealLossStages = DealLossStagesDataStore.getData()
          $scope.optionsDealLossStages = DealLossStagesDataStore.getOptions()

        SalesExecutionDashboard.kpis("member_ids[]": $scope.selectedMemberList.concat($scope.selectedLeaderList), time_period: $scope.kpisChoice).then (data) ->
          $scope.kpis = data[0]

        SalesExecutionDashboard.all("member_ids[]": $scope.selectedMemberList, team_id: $scope.selectedTeamId, member_id: $scope.selectedMemberId).then (data) ->
          $scope.topDeals = data[0].top_deals
          maxValue = data[0].week_pipeline_data
          maxValue = _.max(_.map data[0].week_pipeline_data, (item) =>
              return item.value
          )

          $scope.chartWeekPipeMovement = _.map data[0].week_pipeline_data, (item) =>
            item.styles = {'width': ( if maxValue > 0 then item.value / maxValue * 100 else 0) + "%", 'background-color': item.color}
            return item
          $scope.topActivities = data[0].top_activities

          $scope.productPipelineData = data[0].product_pipeline_data
          updateProductPipelineData()

        SalesExecutionDashboard.forecast(team_id: $scope.selectedTeamId, member_id: $scope.selectedMemberId).then (data) ->
          SalesExecutionDashboardDataStore.setDataQuarterForecast(data);
          $scope.dataQuaterForecast =  SalesExecutionDashboardDataStore.getGraphDataQuarterForecast()
          $scope.optionsQuarterForecast = SalesExecutionDashboardDataStore.getOptionsQuarterForecast()

      $scope.$watch('selectedTeam', () =>
        if ($scope.selectedTeam)
          $scope.selectedTeamId = $scope.selectedTeam.id
          $scope.selectedMember = null
          $scope.selectedMemberId = null
          $scope.selectedMemberList = _.map $scope.selectedTeam.members, (item) =>
            return item.id
          $scope.selectedLeaderList = _.map $scope.selectedTeam.leaders, (item) =>
            return item.id
          calculateKPIs()
      , true);

      $scope.changeMember=(value) =>
        $scope.selectedMember = value
        $scope.selectedMemberId = $scope.selectedMember.id
        $scope.selectedMemberList = [$scope.selectedMember.id]
        $scope.selectedLeaderList = []
        calculateKPIs()

      $scope.changeActivitySummaryChoice=(value) =>
        $scope.activitySummaryChoice = value
        SalesExecutionDashboard.activity_summary("member_ids[]": $scope.selectedMemberList, time_period: $scope.activitySummaryChoice).then (data) ->
          ActivitySummaryDataStore.setData(data)
          $scope.dataActivitySummary = ActivitySummaryDataStore.getData()

      $scope.changeDealLossSummaryChoice=(value) =>
        $scope.dealLossSummaryChoice = value
        SalesExecutionDashboard.deal_loss_summary("member_ids[]": $scope.selectedMemberList, time_period: $scope.dealLossSummaryChoice).then (data) ->
          DealLossSummaryDataStore.setData(data)
          $scope.dataDealLossSummary = DealLossSummaryDataStore.getData()

      $scope.changeDealLossStagesChoice=(value) =>
        $scope.dealLossStagesChoice = value
        SalesExecutionDashboard.deal_loss_stages("member_ids[]": $scope.selectedMemberList, time_period: $scope.dealLossStagesChoice).then (data) ->
          DealLossStagesDataStore.setData(data)
          $scope.dataDealLossStages = DealLossStagesDataStore.getData()
          $scope.optionsDealLossStages = DealLossStagesDataStore.getOptions()

      $scope.changeKPIsChoice=(value) =>
        $scope.kpisChoice = value
        SalesExecutionDashboard.kpis("member_ids[]": $scope.selectedMemberList.concat($scope.selectedLeaderList), time_period: $scope.kpisChoice).then (data) ->
          $scope.kpis = data[0]
        SalesExecutionDashboard.kpis("member_ids[]": $scope.allMemberId.concat($scope.allLeaderId), time_period: $scope.kpisChoice).then (data) ->
          $scope.allKPIs = data[0]

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
        if ($scope.dataQuaterForecast[0].maxValue == 0)
          y = defRect[0][0].height.baseVal.value
        else
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
          .attr("stroke-width", 1)
          .style("stroke-dasharray", ("3, 3"))
          .attr("transform", 'translate(' + width + ', 0)')
          .attr("stroke", "#000000")

      $rootScope.$on 'quarterForecastRendered2', (index) ->
        container = d3.select(".quarter-forecast-chart2")
        svg = container.select("svg")
        nvGroups = svg.selectAll("g.nv-groups")
        rects = nvGroups.selectAll("rect.nv-bar")
        width = rects[0][0].width.baseVal.value

        defRect = svg.selectAll("defs").selectAll("rect")
        if ($scope.dataQuaterForecast[1].maxValue == 0)
          y = defRect[0][0].height.baseVal.value
        else
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
        .attr("stroke-width", 1)
        .style("stroke-dasharray", ("3, 3"))
        .attr("transform", 'translate(' + width + ', 0)')
        .attr("stroke", "#000000")


      $scope.init()
  ]
