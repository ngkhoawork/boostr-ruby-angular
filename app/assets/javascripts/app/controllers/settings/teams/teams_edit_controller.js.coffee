@app.controller 'TeamsEditController',
['$scope', '$modalInstance', '$q', '$filter', 'Team', 'team', 'User'
($scope, $modalInstance, $q, $filter, Team, team, User) ->

  $scope.formType = 'Edit'
  $scope.submitText = 'Update'
  $scope.team = team

  $scope.init = ->
    $q.all({ team: Team.get(team.id), teams: Team.all(), users: User.all()}).then (data) ->
      $scope.team = data.team
      $scope.teams = data.teams
      $scope.users = data.users

  $scope.submitForm = () ->
    $scope.team.member_ids = $scope.team.members
    Team.update(id: $scope.team.id, team: $scope.team).then (team) ->
      $modalInstance.close()

  $scope.$on 'updated_teams', ->
    User.all(true).then (users) ->
      $scope.users = users

  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()
]
