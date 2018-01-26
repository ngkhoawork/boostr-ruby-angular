@app.controller "SettingsPublisherStagesEditController",
  ['$scope', '$rootScope', 'SaleStage', '$modalInstance', 'sale_stages', ($scope, $rootScope, SaleStage, $modalInstance, sale_stages) ->
    $scope.formType = "Edit"
    $scope.submitText = "Update"
    $scope.sale_stages = sale_stages

    $scope.submitForm = () ->
      formValidation()
      if Object.keys($scope.errors).length > 0 then return

      SaleStage.update(id: $scope.sale_stages.id, sales_stage: $scope.sale_stages).then (response) ->
        $rootScope.$broadcast 'updated_stages'
        $scope.cancel()

    formValidation = () ->
      $scope.errors = {}
      fields = ['name', 'probability']

      fields.forEach (key) ->
        field = $scope.sale_stages[key]
        switch key
          when 'name'
            if !field then return $scope.errors[key] = 'Name is required'
          when 'probability'
            if !_.isNumber(field) then return $scope.errors[key] = 'Probability is required'
            if field < 0 then return $scope.errors[key] = 'should be more than 0'
            if field > 100 then return $scope.errors[key] = 'should be less then 100'

    $scope.cancel = ->
      $modalInstance.dismiss()
  ]
