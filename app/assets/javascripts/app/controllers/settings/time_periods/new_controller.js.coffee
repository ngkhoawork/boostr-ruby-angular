@app.controller "SettingsTimePeriodsNewController",
['$scope', 'TimePeriod', '$modalInstance'
($scope, TimePeriod, $modalInstance) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  $scope.time_period = {}

  $scope.submitForm = (form) ->
    form.submitted = true

    if form.$valid
      TimePeriod.create({ time_period: $scope.time_period }, (response) ->
        angular.forEach response.data.errors, (errors, key) ->
          form[key].$dirty = true
          form[key].$setValidity('server', false)
      ).then (time_period) ->
        $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
