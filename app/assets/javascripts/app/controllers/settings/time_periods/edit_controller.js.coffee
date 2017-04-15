@app.controller "SettingsTimePeriodsEditController",
['$scope', 'TimePeriod', '$modalInstance', 'time_period'
($scope, TimePeriod, $modalInstance, time_period) ->

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.time_period = time_period
  $scope.periodTypes = TimePeriod.period_types

  $scope.submitForm = (form) ->
    $scope.errors = {}
    fields = ['name', 'start_date', 'end_date']

    fields.forEach (key) ->
      field = $scope.time_period[key]
      switch key
        when 'name'
          if !field
            return $scope.errors[key] = 'Name is required'
        when 'start_date'
          if !field
            return $scope.errors[key] = 'Start Date is required'
          if field > $scope.time_period.end_date
            return $scope.errors[key] = 'should precede End Date'
        when 'end_date'
          if !field
            return $scope.errors[key] = 'End Date is required'
          if field < $scope.time_period.start_date
            return $scope.errors[key] = 'can\'t precede Start Date'

    return if Object.keys($scope.errors).length > 0

    form.submitted = true
    if form.$valid
      $scope.buttonDisabled = true

      TimePeriod.update(id: $scope.time_period.id, time_period: $scope.time_period).then (time_period) ->
        $scope.time_period = time_period
        $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
