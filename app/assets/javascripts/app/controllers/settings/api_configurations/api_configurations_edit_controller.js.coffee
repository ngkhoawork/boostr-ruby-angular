@app.controller 'ApiConfigurationsEditController',
  ['$scope', '$modalInstance', 'ApiConfiguration', 'api_configuration'
    ($scope, $modalInstance, ApiConfiguration, api_configuration) ->

      $scope.formType = 'Edit'
      $scope.submitText = 'Update'
      $scope.need_change_password = false

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