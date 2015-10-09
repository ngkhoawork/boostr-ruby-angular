@app.controller 'SettingsGeneralController',
['$scope', 'Company',
($scope, Company) ->

  Company.get().then (company) ->
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

  $scope.updateCompany = (params) ->
    Company.update(params).then (company) ->
      $scope.company = company
]
