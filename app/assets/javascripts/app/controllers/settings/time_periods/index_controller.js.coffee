@app.controller "SettingsTimePeriodsController",
['$scope', '$modal', 'TimePeriod',
($scope, $modal, TimePeriod) ->

  $scope.init = () ->
    TimePeriod.all().then (time_periods) ->
      $scope.time_periods = time_periods

  $scope.showModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/time_period_form.html'
      size: 'lg'
      controller: 'SettingsTimePeriodsNewController'
      backdrop: 'static'
      keyboard: false

  $scope.$on 'updated_time_periods', ->
    $scope.init()


  $scope.delete = (time_period) ->
    if confirm('Are you sure you want to delete "' +  time_period.name + '"?')
      TimePeriod.delete time_period, ->
        $location.path("/settings/time_periods/" + $routeParams.id)


  $scope.init()

]
