@app.controller 'ForecastsController',
['$scope', '$routeParams', '$location', 'Forecast', 'TimePeriod', 'WeightedPipeline', 'Revenue'
($scope, $routeParams, $location, Forecast, TimePeriod, WeightedPipeline, Revenue) ->

  $scope.chartBarOptions = {
    responsive: false,
    segmentShowStroke: true,
    segmentStrokeColor: '#fff',
    segmentStrokeWidth: 2,
    percentageInnerCutout: 70,
    animationSteps: 100,
    animationEasing: 'easeOutBounce',
    animateRotate: true,
    animateScale: false,
    scaleLabel: '<%= parseFloat(value).formatMoney() %>',
    legendTemplate : '<ul class="tc-chart-js-legend"><li class="legend_quota"><span class="swatch"></span>Quota</li><% for (var i=datasets.length-1; i>=0; i--){%><li class="legend_<%= datasets[i].label.replace(\'%\', \'\') %>"><span class="swatch" style="background-color:<%= datasets[i].fillColor %>"></span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>',
    multiTooltipTemplate: '<%= value.formatMoney() %>',
    tooltipTemplate: '<%= label %>: <%= value.formatMoney() %>',
    tooltipHideZero: true
  }

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


  $scope.init = () ->
    # TODO: last year, this year, next year OR all years with data?
    $scope.years = [2016, 2017]
    $scope.weightedPipelineDetail = {}
    TimePeriod.all().then (timePeriods) ->
      $scope.timePeriods = timePeriods

      if $routeParams.year
        $scope.year = $routeParams.year

      if $routeParams.time_period_id
        $scope.currentTimePeriod = _.find $scope.timePeriods, (timePeriod) ->
          "#{timePeriod.id}" == $routeParams.time_period_id
      else
        timePeriods.some (timePeriod) ->
          if timePeriod.is_now
            $scope.currentTimePeriod = timePeriod
            return true
          return false
        if not $scope.currentTimePeriod
          $scope.currentTimePeriod = timePeriods[0]

      if $routeParams.team_id
        Forecast.get({ id: $routeParams.team_id, time_period_id: $scope.currentTimePeriod.id, year: $scope.year }).$promise.then (forecast) ->
          $scope.forecast = forecast
          $scope.team = forecast
          $scope.teams = forecast.teams
          $scope.members = forecast.members
          $scope.dataset = [$scope.teams || [], $scope.members || []]
          $scope.setMcSort()
          $scope.setChartData()
      else
        Forecast.query({ time_period_id: $scope.currentTimePeriod.id, year: $scope.year }).$promise.then (forecast) ->
          if forecast.length > 1 # forecast is a quarterly member array
            $scope.forecast = forecast
            $scope.members = forecast
          else # forecast is either a single top-level company or single member object
            $scope.forecast = forecast[0]
            $scope.teams = forecast[0].teams
            if forecast[0].type && forecast[0].type == "member"
              $scope.member = forecast[0]
          $scope.dataset = [$scope.teams || [], $scope.members || []]
          $scope.setMcSort()
          $scope.setChartData()

  $scope.setMcSort = ->
    $scope.sort = new McSort({
      column: "name",
      compareFn: (column, a, b) ->
        switch (column)
          when "name"
            a[column].localeCompare(b[column])
          else
            a[column] - b[column]
      dataset: $scope.dataset
      hasMultipleDatasets: true
    })

  $scope.setChartData = () ->
    members = []
    if $scope.members
      members = $scope.members
    else if $scope.member
      members.push($scope.member)

    # There is a dataset for every stage represented in the user data & a dataset for revenue
    datasets = []
    if $scope.forecast.length > 1
      _.each $scope.forecast, (f) ->
        _.each f.stages, (s) ->
          data = []
          _.each $scope.teams, (t) ->
            data.push(t.weighted_pipeline_by_stage[s.id] || 0)
          if f.leader && (f.leader.revenue > 0 ||  f.leader.weighted_pipeline > 0)
            data.push(f.leader.weighted_pipeline_by_stage[s.id] || 0)
          _.each members, (m) ->
            data.push(m.weighted_pipeline_by_stage[s.id] || 0)
          datasets.push({
            fillColor: s.color,
            label: s.probability + "%",
            data: data
          })
    else
      _.each $scope.forecast.stages, (s) ->
        data = []
        _.each $scope.teams, (t) ->
          data.push(t.weighted_pipeline_by_stage[s.id] || 0)
        if $scope.forecast.leader && ($scope.forecast.leader.revenue > 0 ||  $scope.forecast.leader.weighted_pipeline > 0)
          data.push($scope.forecast.leader.weighted_pipeline_by_stage[s.id] || 0)
        _.each members, (m) ->
          data.push(m.weighted_pipeline_by_stage[s.id] || 0)
        datasets.push({
          fillColor: s.color,
          label: s.probability + "%",
          data: data
        })

    # Add the revenue dataset last so it appears at the bottom of the stacked bar
    data = []
    _.each $scope.teams, (t) ->
      data.push(t.revenue || 0)
    if $scope.forecast.leader && ($scope.forecast.leader.revenue > 0 ||  $scope.forecast.leader.weighted_pipeline > 0)
      data.push($scope.forecast.leader.revenue || 0)
    _.each members, (m) ->
      data.push(m.revenue || 0)
    if data.length > 0
      datasets.push({
        fillColor: '#74d600',
        label: 'Revenue',
        data: data
      })

    # All of the quota markers are printed separately
    quotas = []
    _.each $scope.teams, (t) ->
      quotas.push(t.quota || 0)
    if $scope.forecast.leader && ($scope.forecast.leader.revenue > 0 ||  $scope.forecast.leader.weighted_pipeline > 0)
      quotas.push(0)
    _.each members, (m) ->
      quotas.push(m.quota || 0)

    # Add a list of member names as the x-axis labels
    names = []
    _.each $scope.teams, (t) ->
      if t.quarter
        names.push(t.name + ' Q' + t.quarter)
      else
        names.push(t.name)
    if $scope.forecast.leader && ($scope.forecast.leader.revenue > 0 ||  $scope.forecast.leader.weighted_pipeline > 0)
      names.push($scope.forecast.leader.name)
    _.each members, (m) ->
      if m.quarter
        names.push(m.name + ' Q' + m.quarter)
      else
        names.push(m.name)

    hasRealData = false
    for dataset in datasets
      if hasRealData
        break
      for value in dataset.data
        if value > 0 
          hasRealData = true
          break

    if !hasRealData
      datasets = []

    $scope.chartBarData = {
      labels: names,
      datasets: datasets,
      quotas: quotas
    }


  $scope.toggleWeightedPipelineDetail = (row) ->
    if $scope.weightedPipelineDetail == row
      $scope.weightedPipelineDetail = {}
      $scope.weighted_pipeline = []
    else
      $scope.revenueDetail = {}
      $scope.weighted_pipeline = []
      params = { time_period_id: $scope.currentTimePeriod.id, year: $scope.year, quarter: row.quarter  }
      if row.type == 'member'
        params = _.extend(params, { member_id: row.id })
      else if row.type == 'team'
        params = _.extend(params, { team_id: row.id })

      WeightedPipeline.get(params).then (weighted_pipeline) ->
        $scope.weighted_pipeline = weighted_pipeline
        $scope.sort.weighted_pipeline = new McSort(
          column: "name",
          compareFn: (column, a, b) ->
            switch (column)
              when "name", "client_name"
                a[column].localeCompare(b[column])
              else
                a[column] - b[column]
          dataset: $scope.weighted_pipeline
        )
        $scope.weightedPipelineDetail = row

  $scope.toggleRevenueDetail = (row) ->
    if $scope.revenueDetail == row
      $scope.revenueDetail = {}
      $scope.revenues = []
    else
      $scope.weightedPipelineDetail = {}
      $scope.revenues = []
      params = { time_period_id: $scope.currentTimePeriod.id, year: $scope.year, quarter: row.quarter  }
      if row.type == 'member'
        params = _.extend(params, { member_id: row.id })
      else if row.type == 'team'
        params = _.extend(params, { team_id: row.id })

      Revenue.query(params).$promise.then (revenues) ->
        $scope.revenues = revenues
        $scope.sort.revenues = new McSort(
          column: "client_name",
          compareFn: (column, a, b) ->
            switch (column)
              when "client_name"
                a[column].localeCompare(b[column])
              else
                a[column] - b[column]
          dataset: $scope.revenues
        )
        $scope.revenueDetail = row

  $scope.updateTimePeriod = (time_period_id) ->
    path = []
    path.push "/forecast"
    path.push "/#{$scope.team.id}" if $scope.team
    path.push "?time_period_id=#{time_period_id}" if time_period_id
    $location.url(path.join(''))

  $scope.updateYear = (year) ->
    path = []
    path.push "/forecast"
    path.push "/#{$scope.team.id}" if $scope.team
    path.push "?year=#{year}" if year
    $location.url(path.join(''))

  $scope.init()

  $scope.getSplitAmount = (client_members, member_id, amount) ->
    amount * _.findWhere(client_members, user_id: member_id).share/100.0

  $scope.getTeamSplitAmount = (client_members, members, amount) ->
    sum = 0;
    _.each client_members, (client_member) ->
      user = _.findWhere(members, id: client_member.user_id)
      if user != undefined
        sum += client_member.share*amount/100.0
    return sum
]
