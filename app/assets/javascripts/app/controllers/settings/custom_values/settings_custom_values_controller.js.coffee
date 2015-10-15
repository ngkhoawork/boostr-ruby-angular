@app.controller 'SettingsCustomValuesController',
['$scope', 'CustomValue', 'Stage', 'ClientType',
($scope, CustomValue, Stage, ClientType) ->

  $scope.current = {}
  $scope.constants =
    'Stage': Stage
    'Client Type': ClientType
  $scope.kinds =
    'Stage': 'stage'
    'Client Type': 'client_type'

  CustomValue.all().then (custom_values) ->
    $scope.objects = custom_values
    $scope.setObject($scope.objects[0])

  $scope.sortableOptions =
    stop: () ->
      _.each $scope.current.field.values, (value, index) ->
        value.position = index
        $scope.updateField(value, false)
    axis: 'y'
    opacity: 0.6
    cursor: 'ns-resize'

  $scope.setObject = (object) ->
    $scope.current.object = object
    $scope.setField(object.fields[0])

  $scope.setField = (field) ->
    $scope.current.field = field

  $scope.updateField = (field, warn=true) ->
    kind = $scope.kinds[$scope.current.field.name]
    params = {}
    params[kind] = field

    if field.id
      if field.is_new || !warn || confirm('Are you sure? All existing uses of this ' + $scope.current.field.name.toLowerCase() + ' will be updated.')
        params.id = field.id
        $scope.constants[$scope.current.field.name].update(params)
    else
        $scope.constants[$scope.current.field.name].create(params).then (new_field) ->
          new_field.is_new = true
          _.each $scope.current.field.values, (field, i) ->
            if(field.name == new_field.name)
              $scope.current.field.values[i] = new_field

  $scope.createNewValue = () ->
    switch $scope.current.field.name
      when 'Stages'
        $scope.createNewStage()
      else
        $scope.current.field.values.unshift({ name: 'New ' + $scope.current.field.name })

  $scope.createNewStage = () ->
    new_stage = { name: 'New Stage', probability: 0 }
    $scope.current.field.values.unshift(new_stage)

  $scope.openStageOptions = [
    { value: true, text: 'Open' }
    { value: false, text: 'Closed' }
  ]

]
