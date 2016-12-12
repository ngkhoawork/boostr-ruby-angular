@app.controller "BPsNewController",
['$scope', '$rootScope', '$modalInstance', 'BP', 'TimePeriod'
($scope, $rootScope, $modalInstance, BP, TimePeriod) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  $scope.bp = {
    name: null,
    time_period_id: null,
    due_date: null
  }
  $scope.timePeriods = []

  init = ->
    TimePeriod.all().then (timePeriods) ->
      $scope.timePeriods = timePeriods

  init()

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    BP.create(bp: $scope.bp).then(
      (bp) ->
        $rootScope.$broadcast 'newBP', bp
        $modalInstance.close()
      (resp) ->
        $scope.errors = resp.data.errors
        $scope.buttonDisabled = false
    )
  $scope.cancel = ->
    $modalInstance.dismiss()
]
