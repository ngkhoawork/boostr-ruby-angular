@app.controller 'SettingsCustomValuesController',
['$scope', 'CustomValue', 'Stage',
($scope, CustomValue, Stage) ->

  $scope.current = {}

  CustomValue.all().then (custom_values) ->
    $scope.objects = custom_values
    $scope.setObject($scope.objects[0])

  $scope.setObject = (object) ->
    $scope.current.object = object
    $scope.setField(object.fields[0])

  $scope.setField = (field) ->
    $scope.current.field = field

  $scope.updateStage = (stage) ->
    if confirm('Are you sure? All existing uses of this stage will be updated.')
      Stage.update(id: stage.id, stage: stage).then (stage) ->
        #noop
]
