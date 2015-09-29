@app.controller 'NewUsersController',
['$scope', '$modalInstance', 'User',
($scope, $modalInstance, User) ->

  $scope.formType = "New"
  $scope.submitText = "Invite"
  $scope.user = {}

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    User.invite(user: $scope.user).then (user) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]