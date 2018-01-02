@app.controller "SettingsPublisherStagesController",
  ['$scope', '$modal', '$rootScope', '$filter', 'SaleStage', ($scope, $modal, $rootScope, $filter, SaleStage) ->
    positions = {}

    $scope.init = () ->
      $scope.getSalesStages()

    $scope.getSalesStages = () ->
      SaleStage.sale_stages().then (sale_stages) ->
        $scope.publisher_stages = $filter('orderBy')(sale_stages, ['-active', 'position'])
        positions = getPositions()

    getPositions = ->
      _positions = {}
      _.each $scope.publisher_stages, (t, i) -> _positions[t.id] = i + 1
      _positions

    $scope.$on 'openModal', ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/publisher_stage_form.html'
        size: 'md'
        controller: 'SettingsPublisherStagesNewController'
        backdrop: 'static'
        keyboard: false

    $scope.editModal = (pub_stage) ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/publisher_stage_form.html'
        size: 'md'
        controller: 'SettingsPublisherStagesEditController'
        backdrop: 'static'
        keyboard: false
        resolve:
          sale_stages: ->
            angular.copy pub_stage

    $scope.stageMoved = (index) ->
      $scope.publisher_stages.splice(index, 1)
      newPositions = getPositions()
      if _.isEqual positions, newPositions then return
      changes = _.omit newPositions, (val, key) -> positions[key] == val
      $scope.updateStagePositions(changes)
      positions = newPositions

    $scope.updateStagePositions = (changes) ->
      SaleStage.updatePositions(sales_stages_position: changes).then (response) ->
        $rootScope.$broadcast 'updated_stages'

    $scope.$on 'updated_stages', ->
      $scope.init()

    $scope.init()

  ]