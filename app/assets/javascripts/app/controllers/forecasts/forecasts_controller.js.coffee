@app.controller 'ForecastsController',
['$scope', '$routeParams', 'Forecast',
($scope, $routeParams, Forecast) ->

  if $routeParams.team_id
    Forecast.get($routeParams.team_id).then (team) ->
      $scope.team = team
      $scope.teams = team.teams
      $scope.members = team.members
  else
    Forecast.all().then (forecast) ->
      $scope.forecast = forecast
      $scope.teams = forecast.teams


]
