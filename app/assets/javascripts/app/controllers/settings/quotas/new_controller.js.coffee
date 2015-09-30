@app.controller "SettingsQuotasNewController",
['$scope', '$modalInstance', '$q', '$filter', 'Quota', 'User', 'TimePeriod', 'timePeriod', 'quotas',
($scope, $modalInstance, $q, $filter, Quota, User, TimePeriod, timePeriod, quotas) ->

  $scope.init = () ->
    $scope.formType = "New"
    $scope.submitText = "Create"
    $scope.quota =
      time_period_id: timePeriod.id
    $q.all({time_periods: TimePeriod.all(), users: User.all()}).then (results) ->
      $scope.time_periods = results.time_periods
      $scope.users = $filter('notIn')(results.users, quotas, 'user_id')

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    Quota.create(quota: $scope.quota).then (quota) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()

]