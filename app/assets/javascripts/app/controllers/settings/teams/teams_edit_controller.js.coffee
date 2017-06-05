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
      resetUsers()

  resetUsers = () ->
    $scope.availableUsers = []
    $scope.availableLeaders = []
    if $scope.users
      members = []
      _.each $scope.users, (u) ->
        searchObj = _.find $scope.team.members, (item) ->
          return item == u.id
        if searchObj != undefined
          members.push(u)
        else
          if u.id == $scope.team.leader_id
            $scope.leader = u
            $scope.availableLeaders.push($scope.leader)
          if u && !u['leader?']
            $scope.availableLeaders.push(u)
        
        if u && !u['leader?']
          $scope.availableUsers.push(u)
      $scope.team.members = _.map members, (item) ->
        return item.id

  $scope.memberChanged = () ->
    resetUsers()

  $scope.beforeLeaderChange = (id) ->
    searchObj = _.find $scope.availableLeaders, (item) ->
      return item.id == id
    if searchObj != undefined
      searchObj['leader?'] = false

  $scope.afterLeaderChange = (id) ->
    searchObj = _.find $scope.availableUsers, (item) ->
      return item.id == id
    if searchObj != undefined
      searchObj['leader?'] = true
    resetUsers()

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
