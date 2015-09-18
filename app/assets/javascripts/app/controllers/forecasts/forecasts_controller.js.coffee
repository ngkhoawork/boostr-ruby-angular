@app.controller 'ForecastsController',
['$scope', '$routeParams', '$location', 'Forecast', 'TimePeriod',
($scope, $routeParams, $location, Forecast, TimePeriod) ->

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


  $scope.updateTimePeriod = (time_period_id) ->
    path = []
    path.push "/forecast"
    path.push "/#{$scope.team.id}" if $scope.team
    path.push "?time_period_id=#{time_period_id}" if time_period_id
    $location.url(path.join(''))

  $scope.init()

]
