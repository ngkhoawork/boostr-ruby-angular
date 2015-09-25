@app.controller 'DashboardController',
['$scope', 'Dashboard',
($scope, Dashboard) ->

  Dashboard.get().then (dashboard) ->
    $scope.dashboard = dashboard
]