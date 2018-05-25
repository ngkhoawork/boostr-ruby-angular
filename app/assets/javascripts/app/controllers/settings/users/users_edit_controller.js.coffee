@app.controller "UsersEditController",
['$scope', '$modalInstance', '$filter', 'user', 'User'
($scope, $modalInstance, $filter, user, User) ->
  $scope.user_types = User.user_types_list

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.user = angular.copy(user)

  $scope.submitForm = () ->
    if ($scope.user.team_id == undefined)
      $scope.user.team_id = null
    index = $scope.user.roles.indexOf('admin')
    if ($scope.user.is_admin)
      if (index == -1)
        $scope.user.roles.push('admin')
    else
      if (index > -1)
        $scope.user.roles.splice(index, 1)
    $scope.buttonDisabled = true
    $scope.user.$update ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.dismiss()
]
