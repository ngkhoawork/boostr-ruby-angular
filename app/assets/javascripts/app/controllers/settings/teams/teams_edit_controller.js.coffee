@app.controller 'TeamsEditController',
['$scope', '$modalInstance', '$q', '$filter', 'Team', 'team', 'User'
($scope, $modalInstance, $q, $filter, Team, team, User) ->

  $scope.formType = 'Edit'
  $scope.submitText = 'Update'
  $scope.team = team

  $scope.init = ->
    $q.all({ team: Team.get(team.id), teams: Team.all(), users: User.query().$promise}).then (data) ->
      $scope.team = data.team
      $scope.teams = data.teams
      $scope.users = data.users
      $scope.leader = data.team.leader
      $scope.availableUsers = data.users
      if $scope.users
        members = []
        _.each $scope.users, (u) ->
          searchObj = _.find $scope.team.members, (item) ->
            return item.id == u.id
          if searchObj != undefined
            members.push(u)
        $scope.team.members = members

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    $scope.team.member_ids = $scope.team.members
    Team.update(id: $scope.team.id, team: $scope.team).then (team) ->
      $modalInstance.close()

  $scope.$on 'updated_teams', ->
    User.query().$promise.then (users) ->
      $scope.users = users

  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()
]
