@app.controller "SettingsPublisherStagesController",
  ['$scope', '$modal', '$filter', 'SaleStage', ($scope, $modal, $filter, SaleStage) ->

    $scope.init = () ->
      SaleStage.sale_stages().then (sale_stages) ->
        $scope.publisher_stages = sale_stages

    $scope.createModal = () ->
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

    $scope.$on 'updated_stages', ->
      $scope.init()

    $scope.init()

  ]