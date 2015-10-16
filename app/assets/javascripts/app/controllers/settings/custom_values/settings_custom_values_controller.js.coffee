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
        $scope.constants[$scope.current.field.name].update(params).then () ->
          field.is_new = false
    else
        $scope.constants[$scope.current.field.name].create(params).then (new_field) ->
          new_field.is_new = true
          _.each $scope.current.field.values, (field, i) ->
            if(field.name == new_field.name)
              $scope.current.field.values[i] = new_field

  $scope.deleteField = (field) ->
    if field.id
      kind = $scope.kinds[$scope.current.field.name]

      if !field.used || confirm('Are you sure? This ' + $scope.current.field.name.toLowerCase() + ' is currently being used by a client')
        $scope.constants[$scope.current.field.name].delete(field).then (deleted_value) ->
          $scope.removeField(deleted_value)
    else
      $scope.removeField(field)

  $scope.removeField = (deleted_field) ->
    $scope.current.field.values = _.reject $scope.current.field.values, (value) ->
      deleted_field.id == value.id

  $scope.createNewValue = () ->
    switch $scope.current.field.name
      when 'Stages'
        $scope.createNewStage()
      else
        $scope.newest = { name: 'New ' + $scope.current.field.name }
        $scope.current.field.values.push($scope.newest)


  $scope.createNewStage = () ->
    $scope.newest = { name: 'New Stage', probability: 0 }
    $scope.current.field.values.push($scope.newest)

  $scope.openStageOptions = [
    { value: true, text: 'Open' }
    { value: false, text: 'Closed' }
  ]

]
