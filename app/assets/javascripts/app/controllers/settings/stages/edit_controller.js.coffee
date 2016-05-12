@app.controller "SettingsStagesEditController",
['$scope', '$rootScope', 'Stage', '$modalInstance', 'stage',
($scope, $rootScope, Stage, $modalInstance, stage) ->

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.stage = stage

  $scope.submitForm = (form) ->
    $scope.buttonDisabled = true
    form.submitted = true

    if form.$valid
      $scope.stage.$update(
        ->
          $rootScope.$broadcast 'updated_stages'
          $modalInstance.close()
        (error) ->
          angular.forEach response.data.errors, (errors, key) ->
            form[key].$dirty = true
            form[key].$setValidity('server', false)
            $scope.buttonDisabled = false
      )

  $scope.cancel = ->
    $modalInstance.dismiss()
]
