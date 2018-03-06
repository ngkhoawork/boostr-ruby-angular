@app.controller "SettingsStagesController",
['$scope', '$modal', '$filter', 'Stage',
($scope, $modal, $filter, Stage) ->
  init = () ->
    Stage.query().$promise.then (stages) ->
      $scope.stages = stages
      sortStages()

  sortStages = () ->
    $scope.stages = $filter('orderBy')($scope.stages, ['sales_process_id', '-active', 'position'])

  $scope.sortableOptions =
    stop: () ->
      _.each $scope.stages, (stage, index) ->
        stage.position = index
        stage.$update()
    axis: 'y'
    opacity: 0.6
    cursor: 'ns-resize'

  $scope.$on 'openModal', ->
    modalInstance = $modal.open
      templateUrl: 'modals/stage_form.html'
      size: 'md'
      controller: 'SettingsStagesNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        deal_stage: ->
          {}
    modalInstance.result.then (result) ->
      $scope.stages.push result
      sortStages()

  $scope.edit = (stage) ->
    modalInstance = $modal.open
      templateUrl: 'modals/stage_form.html'
      size: 'md'
      controller: 'SettingsStagesNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        deal_stage: ->
          angular.copy stage
    modalInstance.result.then (result) ->
      index = $scope.stages.indexOf(stage)
      $scope.stages[index] = result
      sortStages()

  init()
]
