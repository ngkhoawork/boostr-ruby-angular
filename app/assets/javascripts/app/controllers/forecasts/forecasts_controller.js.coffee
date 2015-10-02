@app.controller 'ForecastsController',
['$scope', '$routeParams', '$location', 'Forecast', 'TimePeriod', 'WeightedPipeline',
($scope, $routeParams, $location, Forecast, TimePeriod, WeightedPipeline) ->

  $scope.chartOptions = {
    responsive: false,
    segmentShowStroke: true,
    segmentStrokeColor: '#fff',
    segmentStrokeWidth: 2,
    percentageInnerCutout: 60,
    animationSteps: 100,
    animationEasing: 'easeOutBounce',
    animateRotate: true,
    animateScale: false,
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
          $scope.chartData = [
            {
              value: forecast.percent_to_quota,
              color:'#FB6C22',
              highlight: '#FB6C22',
              label: 'Complete'
            },
            {
              value: 100 - forecast.percent_to_quota,
              color: '#FEA673',
              highlight: '#FEA673',
              label: 'Remaining'
            }
          ]
      else
        Forecast.all({ time_period_id: $scope.currentTimePeriod.id }).then (forecast) ->
          $scope.forecast = forecast
          $scope.teams = forecast.teams
          $scope.chartData = [
            {
              value: forecast.percent_to_quota,
              color:'#FB6C22',
              highlight: '#FB6C22',
              label: 'Complete'
            },
            {
              value: 100 - forecast.percent_to_quota,
              color: '#FEA673',
              highlight: '#FEA673',
              label: 'Remaining'
            }
          ]


  $scope.toggleWeightedPipelineDetail = (row) ->
    if $scope.weightedPipelineDetail == row
      $scope.weightedPipelineDetail = {}
      $scope.weighted_pipeline = []
    else
      $scope.weighted_pipeline = []
      $scope.weightedPipelineDetail = row
      params = { time_period_id: $scope.currentTimePeriod.id }
      if row.type == 'member'
        params = _.extend(params, { member_id: row.id })
      else if row.type == 'team'
        params = _.extend(params, { team_id: row.id })

      WeightedPipeline.get(params).then (weighted_pipeline) ->
        $scope.weighted_pipeline = weighted_pipeline

  $scope.updateTimePeriod = (time_period_id) ->
    path = []
    path.push "/forecast"
    path.push "/#{$scope.team.id}" if $scope.team
    path.push "?time_period_id=#{time_period_id}" if time_period_id
    $location.url(path.join(''))

  $scope.init()

]
