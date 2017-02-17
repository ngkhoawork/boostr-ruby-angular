@app.controller 'ApiConfigurationsCreateController',
  ['$scope', '$modalInstance', 'ApiConfiguration', 'CurrentUser'
    ($scope, $modalInstance, ApiConfiguration, CurrentUser) ->

      $scope.formType = 'Create'
      $scope.submitText = 'Create'
      $scope.need_change_password = true

      $scope.api_configuration = {}

      set_defaults = ->
        $scope.api_configuration.integration_type = 'operative'
        $scope.api_configuration.switched_on = true
        CurrentUser.get().$promise.then (user) ->
          $scope.api_configuration.company_id = user.company_id

      set_defaults()

      $scope.submitForm = () ->
        ApiConfiguration.create(api_configuration: $scope.api_configuration).then (api_configuration) ->
          $scope.api_configuration = api_configuration
          $modalInstance.close()

      $scope.cancel = ->
        $modalInstance.close()
  ]