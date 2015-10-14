@app.controller 'ForecastsController',
['$scope', '$routeParams', '$location', 'Forecast', 'TimePeriod', 'WeightedPipeline',
($scope, $routeParams, $location, Forecast, TimePeriod, WeightedPipeline) ->

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

  $scope.init = () ->
    $scope.weightedPipelineDetail = {}
    TimePeriod.all().then (timePeriods) ->
      $scope.timePeriods = timePeriods

      if $routeParams.time_period_id
        $scope.currentTimePeriod = _.find $scope.timePeriods, (timePeriod) ->
          "#{timePeriod.id}" == $routeParams.time_period_id
      else
        $scope.currentTimePeriod = timePeriods[0]

      if $routeParams.team_id
        Forecast.get({ id: $routeParams.team_id, time_period_id: $scope.currentTimePeriod.id }).then (forecast) ->
          $scope.forecast = forecast
          $scope.team = forecast
          $scope.teams = forecast.teams
          $scope.members = forecast.members
          $scope.setChartData()
      else
        Forecast.all({ time_period_id: $scope.currentTimePeriod.id }).then (forecast) ->
          $scope.forecast = forecast
          $scope.teams = forecast.teams
          $scope.setChartData()

  $scope.setChartData = () ->
   # There is a dataset for every stage represented in the user data & a dataset for revenue
    datasets = []
    _.each $scope.forecast.stages, (s) ->
      data = []
      _.each $scope.teams, (t) ->
        data.push(t.weighted_pipeline_by_stage[s.id] || 0)
      if $scope.forecast.leader && ($scope.forecast.leader.revenue > 0 ||  $scope.forecast.leader.weighted_pipeline > 0)
        data.push($scope.forecast.leader.weighted_pipeline_by_stage[s.id] || 0)
      _.each $scope.members, (m) ->
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
    _.each $scope.members, (m) ->
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
    _.each $scope.members, (m) ->
      quotas.push(m.quota || 0)

    # Add a list of member names as the x-axis labels
    names = []
    _.each $scope.teams, (t) ->
      names.push(t.name)
    if $scope.forecast.leader && ($scope.forecast.leader.revenue > 0 ||  $scope.forecast.leader.weighted_pipeline > 0)
      names.push($scope.forecast.leader.name)
    _.each $scope.members, (m) ->
      names.push(m.name)

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
      $scope.weighted_pipeline = []
      params = { time_period_id: $scope.currentTimePeriod.id }
      if row.type == 'member'
        params = _.extend(params, { member_id: row.id })
      else if row.type == 'team'
        params = _.extend(params, { team_id: row.id })

      WeightedPipeline.get(params).then (weighted_pipeline) ->
        $scope.weighted_pipeline = weighted_pipeline
        $scope.weightedPipelineDetail = row

  $scope.updateTimePeriod = (time_period_id) ->
    path = []
    path.push "/forecast"
    path.push "/#{$scope.team.id}" if $scope.team
    path.push "?time_period_id=#{time_period_id}" if time_period_id
    $location.url(path.join(''))

  $scope.init()

]
