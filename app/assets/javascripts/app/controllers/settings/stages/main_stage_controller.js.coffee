@app.controller "MainStageController",
  ['$scope', '$modal', '$filter', 'Stage', ($scope, $modal, $filter, Stage) ->
    $scope.stageTypes = [{name: "Deals"}, {name: "Publishers"}]
    $scope.selectedStage = $scope.stageTypes[0];

    $scope.selectStage = (stage) ->
      $scope.selectedStage = stage
  ]