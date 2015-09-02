@app.controller 'NewTeamsController',
['$scope', '$modalInstance', '$filter', '$q', 'Team', 'team', 'User'
($scope, $modalInstance, $filter, $q, Team, team, User) ->

  $scope.formType = 'New'
  $scope.submitText = 'Create'
  $scope.team = team
  $scope.team.members = []

  $scope.init = ->
    $q.all({ teams: Team.all(), users: User.all()}).then (data) ->
      $scope.teams = data.teams
      $scope.users = data.users
      $scope.availableUsers = $filter('availableUsers') $scope.users

  $scope.submitForm = () ->
    Team.create(team: $scope.team).then (team) ->
      $modalInstance.close()
    User.all(true).then (users) ->
      $scope.users = users

  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()
]
