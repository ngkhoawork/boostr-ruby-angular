@app.controller 'ForecastsController',
['$scope', '$routeParams', '$location', 'Forecast', 'TimePeriod', 'WeightedPipeline',
($scope, $routeParams, $location, Forecast, TimePeriod, WeightedPipeline) ->

  $scope.init = () ->
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
      else
        Forecast.all({ time_period_id: $scope.currentTimePeriod.id }).then (forecast) ->
          $scope.forecast = forecast
          $scope.teams = forecast.teams


  $scope.toggleWeightedPipelineDetail = (member_id) ->
    if $scope.weightedPipelineDetailId == member_id
      $scope.weightedPipelineDetailId = undefined
      $scope.weighted_pipeline = []
    else
      $scope.weighted_pipeline = []
      $scope.weightedPipelineDetailId = member_id
      WeightedPipeline.get({ time_period_id: $scope.currentTimePeriod.id, id: member_id }).then (weighted_pipeline) ->
        $scope.weighted_pipeline = weighted_pipeline

  $scope.updateTimePeriod = (time_period_id) ->
    path = []
    path.push "/forecast"
    path.push "/#{$scope.team.id}" if $scope.team
    path.push "?time_period_id=#{time_period_id}" if time_period_id
    $location.url(path.join(''))

  $scope.init()

]
