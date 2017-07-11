@app.controller 'AsanaConnectConfigurationsEditController',
  ['$window', '$scope', '$modalInstance', 'ApiConfiguration', 'api_configuration', 'IntegrationType', 'AsanaConnect'
    ($window, $scope, $modalInstance, ApiConfiguration, api_configuration, IntegrationType, AsanaConnect) ->

      $scope.formType = 'Edit'
      $scope.submitText = 'Update'
      $scope.need_change_password = false
      $scope.api_configuration = api_configuration
      $scope.api_configuration.asana_connect_details_attributes = api_configuration.asana_connect_details

      $scope.submitForm = () ->
        ApiConfiguration.update(id: $scope.api_configuration.id, api_configuration: $scope.api_configuration).then (api_configuration) ->
          $scope.api_configuration = api_configuration
          $modalInstance.close()
          linkAsana()

      linkAsana = ->
        AsanaConnect.get().$promise.then (connect_data) ->
          $window.location.href = connect_data.url

      $scope.cancel = ->
        $modalInstance.close()
  ]
