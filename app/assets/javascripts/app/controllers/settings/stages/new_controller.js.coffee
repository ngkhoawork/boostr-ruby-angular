@app.controller "SettingsStagesNewController",
['$scope', 'Stage', '$modalInstance'
($scope, Stage, $modalInstance) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  $scope.stage =
    active: true
    open: true

  $scope.submitForm = (form) ->
    $scope.buttonDisabled = true
    form.submitted = true

    if form.$valid
      Stage.create({ stage: $scope.stage }, (response) ->
        angular.forEach response.data.errors, (errors, key) ->
          form[key].$dirty = true
          form[key].$setValidity('server', false)
          $scope.buttonDisabled = false
      ).then (stage) ->
        $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
