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
    if stage.id
      if stage.is_new || confirm('Are you sure? All existing uses of this stage will be updated.')
        Stage.update(id: stage.id, stage: stage).then (stage) ->
          #noop
    else
      Stage.create(stage: stage).then (new_stage) ->
        _.each $scope.current.field.values, (stage, i) ->
          if(stage.name == new_stage.name)
            $scope.current.field.values[i] = new_stage

  $scope.createNewValue = () ->
    switch $scope.current.field.name
      when 'Stages'
        $scope.createNewStage()

  $scope.createNewStage = () ->
    new_stage = { name: 'New Stage', probability: 0, is_new: true }
    $scope.current.field.values.unshift(new_stage)
]
