@app.controller "SettingsStagesController",
['$scope', '$modal', 'Stage',
($scope, $modal, Stage) ->

  $scope.init = () ->
    Stage.all().then (stages) ->
      $scope.stages = stages

  $scope.sortableOptions =
    stop: () ->
      _.each $scope.stages, (stage, index) ->
        stage.position = index
        $scope.updateStage(stage)
    axis: 'y'
    opacity: 0.6
    cursor: 'ns-resize'

  $scope.updateStage = (stage) ->
    Stage.update({ id: stage.id, stage: stage })

  $scope.showModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/stage_form.html'
      size: 'lg'
      controller: 'SettingsStagesNewController'
      backdrop: 'static'
      keyboard: false

  $scope.edit = (stage) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/stage_form.html'
      size: 'lg'
      controller: 'SettingsStagesEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        stage: ->
          stage

  $scope.$on 'updated_stages', ->
    $scope.init()

  $scope.init()

]
