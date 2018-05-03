@app.controller 'NewUsersController',
['$scope', '$modalInstance', 'User', 'onInvite', 'Team'
($scope, $modalInstance, User, onInvite, Team) ->
  $scope.user_types = User.user_types_list

  $scope.init = ->
    $scope.formType = "New"
    $scope.submitText = "Invite"
    $scope.user = {roles: ['user']}
    
    Team.all().then (teams) ->
      $scope.teams = teams

  $scope.submitForm = () ->
    index = $scope.user.roles.indexOf('admin')
    if ($scope.user.is_admin)
      if (index == -1)
        $scope.user.roles.push('admin')
    else
      if (index > -1)
        $scope.user.roles.splice(index, 1)
    $scope.buttonDisabled = true
    User.invite(user: $scope.user).$promise.then (user) ->
      if onInvite
        onInvite(user)
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.dismiss()

  $scope.init()  
]
