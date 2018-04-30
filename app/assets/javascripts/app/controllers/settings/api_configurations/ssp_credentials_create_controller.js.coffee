@app.controller 'SspCredentialsCreateController',
  ['$window', '$scope', '$modalInstance', 'ApiConfiguration', 'IntegrationType'
    ($window, $scope, $modalInstance, ApiConfiguration, IntegrationType) ->
      $scope.formType = 'Create New'
      $scope.submitText = 'Create'
      $scope.need_change_password = false

      $scope.providers = []
      ApiConfiguration.ssp_providers().then (ssp_providers) ->
        $scope.providers = ssp_providers

        $scope.mappedProviders = {}
        for row in $scope.providers
          $scope.mappedProviders[row.id] = "SSP " + row.name

          $scope.api_configuration = {
            ssp_id: $scope.providers[0].id,
            switched_on: true
            integration_provider: $scope.mappedProviders[$scope.providers[0].id]
          }

      $scope.select_provider = () ->
        $scope.api_configuration.integration_provider = $scope.mappedProviders[$scope.api_configuration.ssp_id]

      $scope.submitForm = () ->
        ApiConfiguration.create(api_configuration: $scope.api_configuration).then (api_configuration) ->
          $scope.api_configuration = api_configuration
          $modalInstance.close()


      $scope.cancel = ->
        $modalInstance.close()
  ]
