@app.controller 'SettingsCustomValuesController',
['$scope', 'CustomValue',
($scope, CustomValue) ->

  $scope.current = {}

  CustomValue.all().then (custom_values) ->
    $scope.objects = custom_values
    $scope.setObject($scope.objects[0])

  $scope.setObject = (object) ->
    $scope.current.object = object
    $scope.setField(object.fields[0])

  $scope.setField = (field) ->
    $scope.current.field = field
]
