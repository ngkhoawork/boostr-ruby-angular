@app.controller "UsersEditController",
['$scope', '$modalInstance', '$filter', 'user',
($scope, $modalInstance, $filter, user) ->

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
