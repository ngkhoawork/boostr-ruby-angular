@app.controller 'SalesExecutionDashboardController',
  ['$rootScope',
   '$scope',
   '$q',
   'Team',
   'CurrentUser'
   'SalesExecutionDashboard',
   'SalesExecutionDashboardDataStore',
   'DealLossSummaryDataStore',
   'DealLossStagesDataStore',
   'ActivitySummaryDataStore'
    ($rootScope,
     $scope,
     $q,
     Team,
     CurrentUser,
     SalesExecutionDashboard,
     SalesExecutionDashboardDataStore,
     DealLossSummaryDataStore,
     DealLossStagesDataStore,
     ActivitySummaryDataStore) ->

      $scope.isDisabled = false
      $scope.selectedMember = null
      $scope.selectedTeamId = null
      $scope.selectedMemberId = null

      allMemberEntry = {
        name: 'All',
        id: null,
      }

      $scope.filter =
        selectedMember: allMemberEntry
        selectedTeam: null

      $scope.productPipelineChoice = 'weighted'
      $scope.optionsProductPipeline = SalesExecutionDashboardDataStore.getOptionsProductPipeline()

      $scope.dealLossSummaryChoice = "qtd"
      $scope.optionsDealLossSummary = DealLossSummaryDataStore.getOptions()

      $scope.dealLossStagesChoice = "qtd"
      $scope.kpisChoice = "qtd"
      $scope.members = []

      $scope.activitySummaryChoice = "qtd"
      $scope.optionsActivitySummary = ActivitySummaryDataStore.getOptions()

      $scope.allMemberId = []
      $scope.allLeaderId = []

      class McSort
        constructor: (opts) ->
          @column = opts.column
          @compareFn = opts.compareFn || (-> 0)
          @dataset = opts.dataset || []
          @defaults = opts
          @direction = opts.direction || "asc"
          @hasMultipleDatasets = opts.hasMultipleDatasets || false
          @execute()

        execute: ->
          mcSort = @
          if not @hasMultipleDatasets
            @dataset.sort (a, b) ->
              mcSort.compareFn(mcSort.column, a, b)
            @dataset.reverse() if @direction == "desc"
          else
            @dataset = @dataset.map (row) ->
              row.sort (a, b) ->
                mcSort.compareFn(mcSort.column, a, b)
              row.reverse() if mcSort.direction == "desc"
              row
          @dataset

        reset: ->
          @column = @defaults.column
          @direction = @defaults.direction || "asc"
          @execute()

        toggle: (column) ->
          direction = "asc"
          direction = "desc" if @column == column and @direction == "asc"
          @column = column
          @direction = direction
          @execute()

      setMcSort = ->
        $scope.sort = new McSort({
          column: "client_name",
          compareFn: (column, a, b) ->
            switch (column)
              when "advertiser_name", 'start_date'
                a[column].localeCompare(b[column])
              else
                a[column] - b[column]
          dataset: $scope.topDeals
          hasMultipleDatasets: false
        })

      $scope.sorting =
        key: ''
        reverse: false
      $scope.sortBy = (key) ->
        if $scope.sorting.key != key
          $scope.sorting.key = key
          $scope.sorting.reverse = false
        else
          $scope.sorting.reverse = !$scope.sorting.reverse
      $scope.init = () =>
        Team.all(all_teams: true).then (teams) ->
          all_members = []
          all_leaders = []
          _.each teams, (team) ->
            all_members = [].concat(all_members, team.members)
            all_leaders = [].concat(all_leaders, team.leaders)
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
          $scope.filter.selectedTeam = $scope.teams[0]
          searchAndSetTeam($scope.teams, $scope.currentUser)

          SalesExecutionDashboard.kpis("member_ids[]": allUsers(), time_period: $scope.kpisChoice).then (data) ->
            $scope.allKPIs = data[0]


      updateProductPipelineData = () =>
        if ($scope.productPipelineChoice == "weighted")
          $scope.dataProductPipeline = $scope.productPipelineData.weighted
        else
          $scope.dataProductPipeline = $scope.productPipelineData.unweighted

      calculateKPIs = () =>

        SalesExecutionDashboard.activity_summary("member_ids[]": allSelectedUsers(), time_period: $scope.activitySummaryChoice).then (data) ->
          ActivitySummaryDataStore.setData(data)
          $scope.dataActivitySummary = ActivitySummaryDataStore.getData()
          $scope.optionsActivitySummary = ActivitySummaryDataStore.getOptions()

        SalesExecutionDashboard.deal_loss_summary("member_ids[]": allSelectedUsers(), time_period: $scope.dealLossSummaryChoice).then (data) ->
          DealLossSummaryDataStore.setData(data)
          $scope.dataDealLossSummary = DealLossSummaryDataStore.getData()
          $scope.optionsDealLossSummary = DealLossSummaryDataStore.getOptions()

        SalesExecutionDashboard.deal_loss_stages("member_ids[]": allSelectedUsers(), time_period: $scope.dealLossSummaryChoice).then (data) ->
          DealLossStagesDataStore.setData(data)
          $scope.dataDealLossStages = DealLossStagesDataStore.getData()
          $scope.optionsDealLossStages = DealLossStagesDataStore.getOptions()

        SalesExecutionDashboard.kpis("member_ids[]": allSelectedUsers(), time_period: $scope.kpisChoice).then (data) ->
          $scope.kpis = data[0]

        SalesExecutionDashboard.all("member_ids[]": allSelectedUsers(), team_id: $scope.selectedTeamId, member_id: $scope.selectedMemberId).then (data) ->
          $scope.topDeals = _.map data[0].top_deals, (item) ->
            item.advertiser_name = item.advertiser.name
            item.stage_probability = item.stage.probability
            return item

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
          setMcSort()

        SalesExecutionDashboard.forecast(team_id: $scope.selectedTeamId, member_id: $scope.selectedMemberId).then (data) ->
          SalesExecutionDashboardDataStore.setDataQuarterForecast(data);
          $scope.dataQuaterForecast =  SalesExecutionDashboardDataStore.getGraphDataQuarterForecast()
          $scope.optionsQuarterForecast = SalesExecutionDashboardDataStore.getOptionsQuarterForecast()

      searchAndSetTeam = (teams, user) ->
        for team in teams
          if team.leader_id && team.leader_id == user.id
            $scope.filter.selectedTeam = team
            break
          else if team.id && team.id == user.team_id
            $scope.filter.selectedTeam = team
            break
          if team.children && team.children.length
            searchAndSetTeam team.children, user

      searchAndSetSeller = (members, user) ->
        if !_.isArray members then return
        if _.findWhere members, {id: user.id}
          $scope.filter.selectedMember = user
          return

      $scope.$watch('filter.selectedTeam', () =>
        if ($scope.filter.selectedTeam)
          $scope.members = angular.copy($scope.filter.selectedTeam.members)
          $scope.members.unshift(allMemberEntry);
          $scope.filter.selectedMember = allMemberEntry;
          searchAndSetSeller($scope.filter.selectedTeam.members, $scope.currentUser)
      , true);

      $scope.applyFilter = ->
        $scope.selectedTeam = angular.copy $scope.filter.selectedTeam
        $scope.selectedMember = angular.copy $scope.filter.selectedMember

        if ($scope.selectedMember.id)
          $scope.selectedMemberId = $scope.selectedMember.id
          $scope.selectedMemberList = [$scope.selectedMember.id]
          $scope.selectedLeaderList = []
        else if ($scope.selectedTeam)
          $scope.selectedTeamId = $scope.selectedTeam.id
          $scope.selectedMember = null
          $scope.selectedMemberId = null
          $scope.selectedMemberList = _.map $scope.selectedTeam.members, (item) =>
            return item.id
          $scope.selectedLeaderList = _.map $scope.selectedTeam.leaders, (item) =>
            return item.id

        calculateKPIs()

      $scope.isFilterApplied = ->
        !angular.equals $scope.filter.selectedTeam, $scope.selectedTeam || 
          !angular.equals $scope.filter.selectedMember, $scope.selectedMember

      $scope.changeMember=(value) =>
        $scope.filter.selectedMember = value

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
        SalesExecutionDashboard.kpis("member_ids[]": allSelectedUsers(), time_period: $scope.kpisChoice).then (data) ->
          $scope.kpis = data[0]
        SalesExecutionDashboard.kpis("member_ids[]": allUsers(), time_period: $scope.kpisChoice).then (data) ->
          $scope.allKPIs = data[0]

      $scope.changeProductPipelineChoice=(value) =>
        $scope.productPipelineChoice = value
        updateProductPipelineData()

      allUsers = ->
        [].concat($scope.allMemberId, $scope.allLeaderId)

      allSelectedUsers = ->
        [].concat($scope.selectedMemberList, $scope.selectedLeaderList)

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
