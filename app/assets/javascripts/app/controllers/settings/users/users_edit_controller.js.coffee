@app.controller "UsersEditController",
['$scope', '$modalInstance', '$filter', 'user', 'User'
($scope, $modalInstance, $filter, user, User) ->
  $scope.user_types = User.user_types_list

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.hideEmail = true
  $scope.user = user

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    $scope.user.$update ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.dismiss()
]
