@app.controller 'NewUsersController',
['$scope', '$modalInstance', 'User', 'onInvite',
($scope, $modalInstance, User, onInvite) ->
  $scope.user_types = User.user_types_list

  $scope.formType = "New"
  $scope.submitText = "Invite"
  $scope.user = {}

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    User.invite(user: $scope.user).$promise.then (user) ->
      if onInvite
        onInvite(user)
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.dismiss()
]
