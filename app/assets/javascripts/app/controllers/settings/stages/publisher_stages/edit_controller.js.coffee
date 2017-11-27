@app.controller "SettingsPublisherStagesEditController",
  ['$scope', '$rootScope', 'Stage', '$modalInstance', ($scope, $rootScope, Stage, $modalInstance) ->
    $scope.formType = "Edit"
    $scope.submitText = "Update"


    $scope.submitForm = (form) ->
      console.log(form)
#        $scope.errors = {}
#
#        fields = ['name', 'probability']
#
#        fields.forEach (key) ->
#          field = $scope.stage[key]
#          switch key
#            when 'name'
#              if !field then return $scope.errors[key] = 'Name is required'
#            when 'probability'
#              if !_.isNumber(field) then return $scope.errors[key] = 'Probability is required'
#              if field < 0 then return $scope.errors[key] = 'should be more than 0'
#              if field > 100 then return $scope.errors[key] = 'should be less then 100'
#
#        if Object.keys($scope.errors).length > 0 then return

    $scope.cancel = ->
      $modalInstance.dismiss()
  ]
