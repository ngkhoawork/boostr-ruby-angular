@app.controller 'NewTeamsController',
['$scope', '$modalInstance', 'Team'
($scope, $modalInstance, Team) ->

  $scope.formType = 'New'
  $scope.submitText = 'Create'
  $scope.team = {}
  Team.all().then (teams) ->
    $scope.teams = teams

  $scope.submitForm = () ->
    Team.create(team: $scope.team).then (team) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
