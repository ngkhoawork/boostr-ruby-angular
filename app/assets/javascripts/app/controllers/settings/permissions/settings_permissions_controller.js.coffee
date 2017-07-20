@app.controller 'SettingsPermissionsController',
['$scope', 'Company', 'User'
($scope, Company, User) ->
  $scope.userTypes = User.user_types_list
  Company.get().$promise.then (company) ->
    $scope.company = company

  $scope.updateCompany = ->
    $scope.company.$update()

]
