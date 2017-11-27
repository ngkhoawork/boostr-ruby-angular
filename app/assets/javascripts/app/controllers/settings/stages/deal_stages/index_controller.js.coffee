@app.controller "SettingsStagesController",
['$scope', '$modal', '$filter', 'Stage',
($scope, $modal, $filter, Stage) ->

  $scope.init = () ->
    Stage.query().$promise.then (stages) ->
      $scope.stages = $filter('orderBy')(stages, ['-active', 'position'])

  $scope.sortableOptions =
    stop: () ->
      _.each $scope.stages, (stage, index) ->
        stage.position = index
        $scope.updateStage(stage)
    axis: 'y'
    opacity: 0.6
    cursor: 'ns-resize'

  $scope.updateStage = (stage) ->
    stage.$update()

  $scope.$on 'openDealStageModal', ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/stage_form.html'
      size: 'md'
      controller: 'SettingsStagesNewController'
      backdrop: 'static'
      keyboard: false

  $scope.edit = (stage) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/stage_form.html'
      size: 'md'
      controller: 'SettingsStagesEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        stage: ->
          angular.copy stage

  $scope.$on 'updated_stages', ->
    $scope.init()

  $scope.init()

]
