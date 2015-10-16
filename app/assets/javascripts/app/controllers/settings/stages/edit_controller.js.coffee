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
      Stage.update({ id: $scope.stage.id, stage: $scope.stage }, (response) ->
        angular.forEach response.data.errors, (errors, key) ->
          form[key].$dirty = true
          form[key].$setValidity('server', false)
          $scope.buttonDisabled = false
      ).then (stage) ->
        $rootScope.$broadcast 'updated_stages'
        $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
