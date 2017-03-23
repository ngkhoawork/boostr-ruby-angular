@app.controller 'ApiConfigurationsCreateController',
  ['$scope', '$modalInstance', 'ApiConfiguration', 'IntegrationType',
    ($scope, $modalInstance, ApiConfiguration, IntegrationType) ->

      $scope.formType = 'Create'
      $scope.submitText = 'Create'
      $scope.integration_types = []
      $scope.need_change_password = true

      $scope.api_configuration = {}

      set_defaults = ->
        $scope.api_configuration.integration_type = 'operative'
        $scope.api_configuration.switched_on = true
        IntegrationType.all().then (types) ->
          $scope.integration_types = types

      set_defaults()

      $scope.submitForm = () ->
        ApiConfiguration.create(api_configuration: $scope.api_configuration).then (api_configuration) ->
          $scope.api_configuration = api_configuration
          $modalInstance.close()

      $scope.cancel = ->
        $modalInstance.close()
  ]