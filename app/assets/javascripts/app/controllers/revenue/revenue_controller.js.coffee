@app.controller 'RevenueController',
['$scope', 'Revenue',
($scope, Revenue) ->

  Revenue.all (revenue) ->
    $scope.revenue = revenue
]