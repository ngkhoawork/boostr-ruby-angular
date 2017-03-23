@app.controller 'ApiConfigurationsEditController',
  ['$scope', '$modalInstance', 'ApiConfiguration', 'api_configuration', 'IntegrationType'
    ($scope, $modalInstance, ApiConfiguration, api_configuration, IntegrationType) ->

      $scope.formType = 'Edit'
      $scope.submitText = 'Update'
      $scope.integration_types = []
      IntegrationType.all().then (types) ->
        $scope.integration_types = types

      $scope.need_change_password = false

      $scope.set_neet_set_password = (val) ->
        $scope.need_change_password = val

      $scope.api_configuration = api_configuration

      $scope.submitForm = () ->
        unless $scope.need_change_password
          delete $scope.api_configuration['password']
        ApiConfiguration.update(id: $scope.api_configuration.id, api_configuration: $scope.api_configuration).then (api_configuration) ->
          $scope.api_configuration = api_configuration
          $modalInstance.close()

      $scope.cancel = ->
        $modalInstance.close()
  ]