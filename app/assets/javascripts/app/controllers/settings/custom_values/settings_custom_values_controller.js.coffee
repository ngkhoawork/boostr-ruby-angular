@app.controller 'SettingsCustomValuesController',
['$scope', 'CustomValue', 'Option',
($scope, CustomValue, Option) ->

  $scope.current = {}

  CustomValue.all().then (custom_values) ->
    $scope.objects = custom_values
    $scope.setObject($scope.objects[0])

  $scope.sortableOptions =
    stop: () ->
      _.each $scope.current.field.options, (option, index) ->
        option.position = index
        $scope.updateOption(option, false)
    axis: 'y'
    opacity: 0.6
    cursor: 'ns-resize'

  $scope.setObject = (object) ->
    $scope.current.object = object
    $scope.setField(object.fields[0])

  $scope.setField = (field) ->
    $scope.current.field = field

  $scope.updateOption = (option, warn=true) ->
    if option.id
      if option.is_new || !warn || confirm('Are you sure? All existing uses of this ' + $scope.current.field.name.toLowerCase() + ' will be updated.')
        Option.update({id: option.id, option: option, field_id: $scope.current.field.id }).then () ->
          option.is_new = false
    else
        Option.create({ option: option, field_id: $scope.current.field.id }).then (new_option) ->
          new_option.is_new = true
          _.each $scope.current.field.options, (option, i) ->
            if(option.name == new_option.name)
              $scope.current.field.options[i] = new_option

  $scope.deleteOption = (option) ->
    if option.id
      if !option.used || confirm('Are you sure? This ' + $scope.current.field.name.toLowerCase() + ' is currently being used')
        Option.delete({ id: option.id, field_id: $scope.current.field.id }).then (deleted_option) ->
          $scope.removeOption(deleted_option)
    else
      $scope.removeOption(option)

  $scope.removeOption = (deleted_option) ->
    $scope.current.field.options = _.reject $scope.current.field.options, (option) ->
      deleted_option.id == option.id

  $scope.createNewValue = () ->
    $scope.newest = { name: 'New ' + $scope.current.field.name }
    $scope.current.field.options.push($scope.newest)



 # Stage stuff... goes somewhere else

  $scope.createNewStage = () ->
    $scope.newest = { name: 'New Stage', probability: 0 }
    $scope.current.field.options.push($scope.newest)

  $scope.openStageOptions = [
    { option: true, text: 'Open' }
    { option: false, text: 'Closed' }
  ]

]
