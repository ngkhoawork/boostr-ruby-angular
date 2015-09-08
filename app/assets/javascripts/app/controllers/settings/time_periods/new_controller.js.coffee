@app.controller "SettingsTimePeriodsNewController",
['$scope', 'TimePeriod', '$modalInstance'
($scope, TimePeriod, $modalInstance) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  $scope.time_period = {}

  $scope.submitForm = () ->
    TimePeriod.create(time_period: $scope.time_period).then (time_period) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
