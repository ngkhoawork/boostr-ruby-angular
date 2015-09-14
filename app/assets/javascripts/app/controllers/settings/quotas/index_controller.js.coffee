@app.controller "SettingsQuotasController",
['$scope', '$routeParams', '$location', '$modal', 'Quota', 'TimePeriod',
($scope, $routeParams, $location, $modal, Quota, TimePeriod) ->

  $scope.init = () ->
    TimePeriod.all().then (timePeriods) ->
      $scope.timePeriods = timePeriods

      if $routeParams.time_period_id
        $scope.currentTimePeriod = _.find $scope.timePeriods, (timePeriod) ->
          "#{timePeriod.id}" == $routeParams.time_period_id
      else
        $scope.currentTimePeriod = timePeriods[0]
      $scope.getQuotas()

  $scope.getQuotas = () ->
    Quota.all({time_period_id: $scope.currentTimePeriod.id}).then (quotas) ->
      $scope.quotas = quotas

  $scope.updateTimePeriod = (time_period_id) ->
    $location.path("/settings/quotas/#{time_period_id}")

  $scope.updateQuota = (quota) ->
    Quota.update({id: quota.id, quota: quota})

  $scope.showModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/user_quota_form.html'
      size: 'lg'
      controller: 'SettingsQuotasNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        timePeriod: ->
          $scope.currentTimePeriod
        quotas: ->
          $scope.quotas

  $scope.$on 'updated_quotas', ->
    $scope.getQuotas()

  $scope.init()

]