@app.controller 'SettingsActivityTypesController',
['$scope', 'ActivityType'
($scope, ActivityType) ->

  ActivityType.all().then (data) ->
    $scope.activity_types = data

]
