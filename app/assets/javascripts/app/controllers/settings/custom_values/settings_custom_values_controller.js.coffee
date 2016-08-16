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

  $scope.sortableSuboptions =
    stop: () ->
      _.each $scope.current.option.suboptions, (suboption, index) ->
        suboption.position = index
        $scope.updateSubOption(suboption, false)
    axis: 'y'
    opacity: 0.6
    cursor: 'ns-resize'

  $scope.setObject = (object) ->
    $scope.current.object = object
    $scope.setField(object.fields[0])

  $scope.setField = (field) ->
    $scope.current.field = field
    $scope.setOption(field.options[0])

  $scope.setOption = (option) ->
    $scope.current.option = option

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
            $scope.setOption(new_option)

  $scope.updateSubOption = (suboption, warn=true) ->
    if suboption.id
      if suboption.is_new || !warn || confirm('Are you sure? All existing uses of this ' + $scope.current.field.name.toLowerCase() + ' will be updated.')
        Option.update({id: suboption.id, option: suboption, option_id: $scope.current.option.id }).then () ->
          suboption.is_new = false
    else
      Option.create({ option: suboption, option_id: $scope.current.option.id }).then (new_suboption) ->
        new_suboption.is_new = true
        _.each $scope.current.option.suboptions, (option, i) ->
          if(option.name == new_suboption.name)
            $scope.current.option.suboptions[i] = new_suboption

  $scope.deleteOption = (option) ->
    if option.id
      if !option.used || confirm('Are you sure? This ' + $scope.current.field.name.toLowerCase() + ' is currently being used')
        Option.delete({ id: option.id, field_id: $scope.current.field.id }).then (deleted_option) ->
          $scope.removeOption(deleted_option)
    else
      $scope.removeOption(option)

  $scope.deleteSubOption = (suboption) ->
    if suboption.id
      if !suboption.used || confirm('Are you sure? This ' + $scope.current.field.name.toLowerCase() + ' is currently being used')
        Option.delete({ id: suboption.id, option_id: $scope.current.option.id }).then (deleted_suboption) ->
          $scope.removeSubOption(deleted_suboption)
    else
      $scope.removeSubOption(suboption)

  $scope.removeOption = (deleted_option) ->
    $scope.current.field.options = _.reject $scope.current.field.options, (option) ->
      deleted_option.id == option.id

  $scope.removeSubOption = (deleted_suboption) ->
    $scope.current.option.suboptions = _.reject $scope.current.option.suboptions, (suboption) ->
      deleted_suboption.id == suboption.id

  $scope.createNewValue = () ->
    $scope.newest = { name: '' }
    $scope.current.field.options.push($scope.newest)

  $scope.createNewSubOption = () ->
    $scope.newest = { name: '' }
    $scope.current.option.suboptions.push($scope.newest)
]
