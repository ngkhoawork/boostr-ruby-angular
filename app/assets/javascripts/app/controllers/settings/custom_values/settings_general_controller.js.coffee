@app.controller 'SettingsGeneralController',
['$scope', 'Company', 'Stage'
($scope, Company, Stage) ->

  Company.get().$promise.then (company) ->
    $scope.company = company

  $scope.days = [
    { id: 0, name: 'Sunday' }
    { id: 1, name: 'Monday' }
    { id: 2, name: 'Tuesday' }
    { id: 3, name: 'Wednesday' }
    { id: 4, name: 'Thursday' }
    { id: 5, name: 'Friday' }
    { id: 6, name: 'Saturday' }
  ]

  $scope.updateCompany = ->
    $scope.company.$update()

  $scope.updateStage = (stage) ->
    stage.$update()

  $scope.stages = []
  Stage.query().$promise.then (stages) ->
    $scope.stages = stages
]
