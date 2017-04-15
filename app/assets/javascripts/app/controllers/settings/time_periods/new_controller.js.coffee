@app.controller "SettingsTimePeriodsNewController",
['$scope', 'TimePeriod', '$modalInstance'
($scope, TimePeriod, $modalInstance) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  $scope.time_period = {visible: true}
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

      TimePeriod.create({ time_period: $scope.time_period }, (response) ->
        angular.forEach response.data.errors, (errors, key) ->
          form[key].$dirty = true
          form[key].$setValidity('server', false)
        $scope.buttonDisabled = false
      ).then (time_period) ->
        $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
