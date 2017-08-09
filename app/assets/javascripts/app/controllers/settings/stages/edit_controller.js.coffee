@app.controller "SettingsStagesEditController",
['$scope', '$rootScope', 'Stage', '$modalInstance', 'stage',
($scope, $rootScope, Stage, $modalInstance, stage) ->

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.stage = stage

  $scope.submitForm = (form) ->
    $scope.errors = {}

    fields = ['name', 'probability']

    fields.forEach (key) ->
      field = $scope.stage[key]
      switch key
        when 'name'
          if !field then return $scope.errors[key] = 'Name is required'
        when 'probability'
          if !_.isNumber(field) then return $scope.errors[key] = 'Probability is required'
          if field < 0 then return $scope.errors[key] = 'should be more than 0'
          if field > 100 then return $scope.errors[key] = 'should be less then 100'

    if Object.keys($scope.errors).length > 0 then return

    $scope.stage.$update(
      ->
        $rootScope.$broadcast 'updated_stages'
        $modalInstance.close()
      (error) ->
        angular.forEach response.data.errors, (errors, key) ->
          $scope.errors = response.data.errors
    )

  $scope.cancel = ->
    $modalInstance.dismiss()
]
