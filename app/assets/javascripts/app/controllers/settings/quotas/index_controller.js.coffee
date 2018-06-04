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

  $scope.showNewModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/user_quota_form.html'
      size: 'lg'
      controller: 'SettingsQuotasNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        timePeriod: ->
          $scope.currentTimePeriod
        quota: ->

  $scope.showEditModal = (quota) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/user_quota_form.html'
      size: 'lg'
      controller: 'SettingsQuotasNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        timePeriod: ->
          $scope.currentTimePeriod
        quota: ->
          quota

  $scope.delete = (quota) ->
    if confirm('Are you sure you want to delete quota record of "' +  quota.user_name + '"?')
      Quota.delete quota, ->
        $location.path("/settings/quotas/#{$routeParams.time_period_id}")

  $scope.$on 'updated_quotas', ->
    $scope.getQuotas()

  $scope.init()

]