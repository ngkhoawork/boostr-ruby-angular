@app.controller 'SettingsSmartInsightsController',
['$scope', 'Company', 'Stage', 'User', 'KPI',
($scope, Company, Stage, User, KPI) ->
  Company.get().$promise.then (company) ->
    $scope.company = company

  $scope.updateCompany = ->
    $scope.company.$update()

  $scope.updateStage = (stage) ->
    stage.$update()

  updateUserTimeout = null
  $scope.updateUser = (user) ->
    if updateUserTimeout
      clearTimeout(updateUserTimeout)
    setTimeout(
      ->
        if user.win_rate > 1
          user.win_rate = user.win_rate / 100
        user.$update()
      250
    )

  $scope.calculateKPIs = ->
    KPI.all().then (users) ->
      $scope.users = users

  $scope.stages = []
  Stage.query().$promise.then (stages) ->
    $scope.stages = stages

  $scope.users = []
  User.query().$promise.then (users) ->
    $scope.users = users
]
