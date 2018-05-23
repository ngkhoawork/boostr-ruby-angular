@app.controller 'ActivityTypeModalController',
  ['$scope', '$modalInstance', 'ActivityType', 'iconsList', 'activityType',
    ( $scope,   $modalInstance,   ActivityType,   iconsList,   activityType ) ->

      $scope.submitText = if activityType then 'Save' else 'Create'
      $scope.formType = if activityType then 'Edit' else 'Add New'
      $scope.iconsList = iconsList

      $scope.activityType = activityType ||
      name: ''
      css_class: iconsList[0]
      active: true
      action: ''

      $scope.cancel = ->
        $modalInstance.close()

      $scope.submitForm = ->
        $scope.errors = {}

        _.each $scope.activityType, (val, key) ->
          switch key
            when 'name'
              if !val then $scope.errors[key] = 'Name is required'
            when 'css_class'
              if !val then $scope.errors[key] = 'Icon is required'
            when 'action'
              if !val then $scope.errors[key] = 'Action is required'

        if _.keys($scope.errors).length then return
        $scope.buttonDisabled = true

        if !activityType
          ActivityType.create($scope.activityType).then (data) ->
            $scope.buttonDisabled = false
            $scope.cancel()
        else
          ActivityType.update($scope.activityType).then (data) ->
            $scope.buttonDisabled = false
            $scope.cancel()


  ]
