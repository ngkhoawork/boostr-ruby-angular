@app.controller "SettingsQuotasController",
['$scope', '$routeParams', '$location', 'Quota', 'TimePeriod',
($scope, $routeParams, $location, Quota, TimePeriod) ->

  $scope.init = () ->
    TimePeriod.all().then (timePeriods) ->
      $scope.timePeriods = timePeriods

      if $routeParams.time_period_id
        $scope.currentTimePeriod = _.find $scope.timePeriods, (timePeriod) ->
          "#{timePeriod.id}" == $routeParams.time_period_id
      else
        $scope.currentTimePeriod = timePeriods[0]

      Quota.all({time_period_id: $scope.currentTimePeriod.id}).then (quotas) ->
        $scope.quotas = quotas

  $scope.updateTimePeriod = (time_period_id) ->
    $location.path("/settings/quotas/#{time_period_id}")

  $scope.updateQuota = (quota) ->
    Quota.update({id: quota.id, quota: quota})

  $scope.init()

]