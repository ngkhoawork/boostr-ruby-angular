@app.controller "MainStageController",
  ['$scope', '$modal', '$filter', 'Stage', '$rootScope', ($scope, $modal, $filter, Stage, $rootScope) ->
    $scope.stageTypes = [{name: "Deals"}, {name: "Publishers"}]
    $scope.selectedStage = $scope.stageTypes[0];

    $scope.selectStage = (stage) ->
      $scope.selectedStage = stage

    $scope.createStageModal = () ->
      if $scope.selectedStage.name == 'Deals'
        $rootScope.$broadcast 'openDealStageModal'
      else
        $rootScope.$broadcast 'openPublisherStageModal'
  ]