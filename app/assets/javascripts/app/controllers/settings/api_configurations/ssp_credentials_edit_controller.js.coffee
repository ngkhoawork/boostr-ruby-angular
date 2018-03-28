@app.controller 'SspCredentialsEditController',
  ['$window', '$scope', '$modalInstance', 'ApiConfiguration', 'api_configuration', 'IntegrationType'
    ($window, $scope, $modalInstance, ApiConfiguration, api_configuration, IntegrationType) ->
      $scope.formType = 'Edit'
      $scope.submitText = 'Update'
      $scope.need_change_password = false

      $scope.api_configuration = api_configuration

      $scope.submitForm = () ->
        ApiConfiguration.update_ssp(id: $scope.api_configuration.id, api_configuration: $scope.api_configuration).then (api_configuration) ->
          $scope.api_configuration = api_configuration
          $modalInstance.close()

      $scope.cancel = ->
        $modalInstance.close()
  ]
