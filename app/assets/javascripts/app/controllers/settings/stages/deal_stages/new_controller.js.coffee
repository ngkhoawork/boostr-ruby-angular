@app.controller "SettingsStagesNewController",
['$scope', '$rootScope', 'Stage', '$modalInstance', 'SalesProcess', 'deal_stage'
($scope, $rootScope, Stage, $modalInstance, SalesProcess, deal_stage) ->
  $scope.salesProcesses = []

  init = () ->
    if _.isEmpty(deal_stage)
      $scope.formType = 'New'
      $scope.submitText = 'Create'
      $scope.stage = new Stage(
        active: true
        open: true
      )
    else
      $scope.formType = 'Edit'
      $scope.submitText = 'Save'
      $scope.stage = deal_stage

    SalesProcess.all({active: true}).then (salesProcesses) ->
      $scope.salesProcesses = salesProcesses

  $scope.submitForm = (form) ->
    $scope.errors = {}
    fields = {'name': 'Name', 'probability': 'Probability', 'sales_process_id': 'Sales Process'}

    for key, value of fields
      field = $scope.stage[key]
      switch key
        when 'name', 'sales_process_id'
          if !field then $scope.errors[key] = value + ' is required'
        when 'probability'
          if !_.isNumber(field)
            $scope.errors[key] = 'Probability is required'
          else if field < 0 
            $scope.errors[key] = 'should be more than 0'
          else if field > 100
            $scope.errors[key] = 'should be less then 100'

    if !_.isEmpty($scope.errors) then return

    if $scope.formType == 'New'
      $scope.stage.$save(
        (stage)->
          $modalInstance.close(stage)
        (response) ->
          $scope.errors = response.data.errors
      )
    else
      $scope.stage.$update(
        (stage)->
          $modalInstance.close(stage)
        (response) ->
          $scope.errors = response.data.errors
      )

  $scope.cancel = ->
    $modalInstance.dismiss()

  init()
]
