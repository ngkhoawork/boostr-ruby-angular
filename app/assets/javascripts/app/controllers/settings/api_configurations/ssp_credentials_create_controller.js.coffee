@app.controller 'SspCredentialsCreateController',
  ['$window', '$scope', '$modalInstance', 'ApiConfiguration', 'IntegrationType'
    ($window, $scope, $modalInstance, ApiConfiguration, IntegrationType) ->
      $scope.formType = 'Create New'
      $scope.submitText = 'Create'
      $scope.need_change_password = false
      $scope.api_configuration = {
        type_id: 1,
        switched_on: true
        integration_provider: 'Ssp'
      }

      $scope.providers = [
        {id: 1, name: 'SpotX'},
        {id: 2, name: 'Rubicon'}
      ]

      $scope.select_provider = () ->

      $scope.submitForm = () ->
        ApiConfiguration.create(api_configuration: $scope.api_configuration).then (api_configuration) ->
          $scope.api_configuration = api_configuration
          $modalInstance.close()


      $scope.cancel = ->
        $modalInstance.close()
  ]
