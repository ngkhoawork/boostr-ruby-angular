@app.controller "SettingsTimePeriodsEditController",
['$scope', 'TimePeriod', '$modalInstance', 'time_period'
($scope, TimePeriod, $modalInstance, time_period) ->

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.time_period = time_period

  $scope.submitForm = (form) ->
    $scope.buttonDisabled = true
    form.submitted = true

    if form.$valid
      TimePeriod.update(id: $scope.time_period.id, time_period: $scope.time_period).then (time_period) ->
        $scope.time_period = time_period
        $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
