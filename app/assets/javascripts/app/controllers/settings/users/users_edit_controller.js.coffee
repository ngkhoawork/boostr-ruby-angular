@app.controller "UsersEditController",
['$scope', '$modalInstance', '$filter', 'User', 'user',
($scope, $modalInstance, $filter, User, user) ->

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.hideEmail = true
  $scope.user = user
  
  $scope.submitForm = () ->
    User.update(id: $scope.user.id, user: $scope.user).then (user) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
