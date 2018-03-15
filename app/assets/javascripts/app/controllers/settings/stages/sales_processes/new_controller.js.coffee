@app.controller "SettingsSalesProcessNewController",
  ['$scope', '$rootScope', 'SalesProcess', '$modalInstance', 'sales_process'
    ($scope, $rootScope, SalesProcess, $modalInstance, sales_process) ->
      init = () ->
        if _.isEmpty(sales_process)
          $scope.formType = 'New'
          $scope.submitText = 'Create'
          $scope.sales_process = {active: true}
        else
          $scope.formType = 'Edit'
          $scope.submitText = 'Save'
          $scope.sales_process = sales_process
      
      $scope.submitForm = () ->
        formValidation()
        if _.isEmpty($scope.errors)
          if $scope.formType == 'New'
            SalesProcess.create(sales_process: $scope.sales_process).then (sales_process) ->
              $modalInstance.close(sales_process)
          else
            SalesProcess.update(id: sales_process.id, sales_process: $scope.sales_process).then (sales_process) ->
              $modalInstance.close(sales_process)            

      formValidation = () ->
        $scope.errors = {}
        fields = {'name': 'Name'}
        for key, value of fields
          field = $scope.sales_process[key]
          if !field then return $scope.errors[key] = value + ' is required'

      $scope.cancel = ->
        $modalInstance.dismiss()

      init()
  ]
