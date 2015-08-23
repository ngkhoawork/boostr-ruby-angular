@app.controller 'NewTeamsController',
['$scope', '$modalInstance', '$filter', 'Team', 'team', 'User'
($scope, $modalInstance, $filter, Team, team, User) ->

  $scope.formType = 'New'
  $scope.submitText = 'Create'
  $scope.team = team
  $scope.team.member_ids = []

  Team.all().then (teams) ->
    $scope.teams = teams
  User.all().then (users) ->
    $scope.users = users
    $scope.availableUsers = $filter('availableUsers') users

  $scope.submitForm = () ->
    Team.create(team: $scope.team).then (team) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
