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

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    $scope.team.member_ids = $scope.team.members
    Team.create(team: $scope.team).then (team) ->
      $modalInstance.close()

  $scope.$on 'updated_teams', ->
    User.all(true).then (users) ->
      $scope.users = users

  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()
]
