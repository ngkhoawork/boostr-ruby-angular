@app.controller 'NewUsersController',
['$scope', '$modalInstance', 'User', 'onInvite', 'Team', 'options'
($scope, $modalInstance, User, onInvite, Team, options) ->
  $scope.user_types = User.user_types_list

  init = ->
    $scope.formType = "New"
    $scope.submitText = "Invite"
    $scope.user = {roles: ['user']}

  $scope.submitForm = () ->
    $scope.errors = {}
    if options.allUsers
      options.allUsers.forEach (exictUser) ->
        if exictUser.email == $scope.user.email
          $scope.errors.email = ['Such email is already exist']
    index = $scope.user.roles.indexOf('admin')
    if ($scope.user.is_admin)
      if (index == -1)
        $scope.user.roles.push('admin')
    else
      if (index > -1)
        $scope.user.roles.splice(index, 1)
    if _.isEmpty($scope.errors)
      $scope.buttonDisabled = true
      User.invite(user: $scope.user).$promise.then(
        (user) ->
          if onInvite
            onInvite(user)
          if options.assignToAgreement
            $modalInstance.close(user)
            return
          $modalInstance.close()
        (reject) ->
          $scope.errors = reject.data.errors
          $scope.buttonDisabled = false
      )

  $scope.cancel = -> $modalInstance.dismiss()

  init()  
]
