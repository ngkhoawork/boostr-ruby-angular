@app.controller 'DataFeedConfigurationsCreateController',
  ['$scope', '$modalInstance', 'ApiConfiguration', 'IntegrationType',
    ($scope, $modalInstance, ApiConfiguration, IntegrationType) ->

      $scope.formType = 'Create'
      $scope.submitText = 'Create'
      $scope.need_change_password = true
      $scope.api_configuration = {}

      set_defaults = ->
        $scope.api_configuration.integration_provider = 'Operative Datafeed'
        $scope.api_configuration.switched_on = true

      set_defaults()

      $scope.submitForm = () ->
        ApiConfiguration.create(api_configuration: $scope.api_configuration).then (api_configuration) ->
          $scope.api_configuration = api_configuration
          $modalInstance.close()

      $scope.cancel = ->
        $modalInstance.close()
  ]