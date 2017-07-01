@app.controller 'AsanaConnectConfigurationsCreateController',
  ['$window', '$scope', '$modalInstance', 'ApiConfiguration', 'IntegrationType', 'AsanaConnect'
  ($window, $scope, $modalInstance, ApiConfiguration, IntegrationType, AsanaConnect) ->

      $scope.formType = 'Create'
      $scope.submitText = 'Create'
      $scope.need_change_password = false
      $scope.api_configuration = {}
      $scope.api_configuration.switched_on = true
      $scope.api_configuration.integration_provider = 'Asana Connect'
      $scope.api_configuration.trigger_on_deal_percentage = 0

      $scope.submitForm = () ->
        ApiConfiguration.create(api_configuration: $scope.api_configuration).then (api_configuration) ->
          $scope.api_configuration = api_configuration
          $modalInstance.close()
          linkAsana()

      linkAsana = ->
        AsanaConnect.get().$promise.then (connect_data) ->
          $window.location.href = connect_data.url

      $scope.cancel = ->
        $modalInstance.close()
  ]