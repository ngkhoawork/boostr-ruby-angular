@app.controller 'SettingsSmartInsightsController',
['$scope', 'Company', 'Stage'
($scope, Company, Stage) ->
  Company.get().$promise.then (company) ->
    $scope.company = company

  $scope.updateCompany = ->
    $scope.company.$update()

  $scope.updateStage = (stage) ->
    stage.$update()

  $scope.stages = []
  Stage.query().$promise.then (stages) ->
    $scope.stages = stages
]
