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

  $scope.init()

]