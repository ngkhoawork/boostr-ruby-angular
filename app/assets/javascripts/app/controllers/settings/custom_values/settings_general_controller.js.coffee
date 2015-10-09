@app.controller 'SettingsGeneralController',
['$scope', 'Company',
($scope, Company) ->

  Company.get().then (company) ->
    $scope.company = company

  $scope.days = [
    'Sunday'
    'Monday'
    'Tuesday'
    'Wednesday'
    'Thursday'
    'Friday'
    'Saturday'
  ]

  $scope.updateCompany = (params) ->
    Company.update(params).then (company) ->
      $scope.company = company
]
