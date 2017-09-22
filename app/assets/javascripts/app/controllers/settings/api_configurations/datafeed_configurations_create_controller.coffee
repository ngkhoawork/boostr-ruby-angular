@app.controller 'DataFeedConfigurationsCreateController',
  ['$scope', '$modalInstance', 'ApiConfiguration', 'IntegrationType',
    ($scope, $modalInstance, ApiConfiguration, IntegrationType) ->

      $scope.formType = 'Create'
      $scope.submitText = 'Create'
      $scope.need_change_password = true
      $scope.api_configuration = {
        integration_provider: 'Operative Datafeed',
        switched_on: true,
        datafeed_configuration_details: { auto_close_deals: false }
      }

      $scope.submitForm = () ->
        $scope.api_configuration.datafeed_configuration_details_attributes = $scope.api_configuration.datafeed_configuration_details
        ApiConfiguration.create(api_configuration: $scope.api_configuration).then (api_configuration) ->
          $scope.api_configuration = api_configuration
          $modalInstance.close()

      $scope.cancel = ->
        $modalInstance.close()
  ]
