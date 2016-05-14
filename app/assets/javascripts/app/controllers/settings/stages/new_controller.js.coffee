@app.controller "SettingsStagesNewController",
['$scope', '$rootScope', 'Stage', '$modalInstance'
($scope, $rootScope, Stage, $modalInstance) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  $scope.stage = new Stage(
    active: true
    open: true
  )

  $scope.submitForm = (form) ->
    $scope.buttonDisabled = true
    form.submitted = true

    if form.$valid
      $scope.stage.$save(
        ->
          $rootScope.$broadcast 'updated_stages'
          $modalInstance.close()
        (response) ->
          angular.forEach response.data.errors, (errors, key) ->
            form[key].$dirty = true
            form[key].$setValidity('server', false)
            $scope.buttonDisabled = false
      )

  $scope.cancel = ->
    $modalInstance.dismiss()
]
