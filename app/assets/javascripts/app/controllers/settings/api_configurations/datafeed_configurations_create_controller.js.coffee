@app.controller 'DataFeedConfigurationsCreateController',
  ['$scope', '$modalInstance', 'ApiConfiguration', 'IntegrationType',
    ($scope, $modalInstance, ApiConfiguration, IntegrationType) ->

      $scope.errors = {}
      $scope.formType = 'Create'
      $scope.submitText = 'Create'
      $scope.need_change_password = true
      $scope.api_configuration = {
        integration_provider: 'Operative Datafeed',
        switched_on: true,
        datafeed_configuration_details: { auto_close_deals: false }
      }

      ApiConfiguration.metadata(integration_provider: 'Operative Datafeed').then (data) ->
        $scope.revenue_calculation_patterns = data.revenue_calculation_patterns

      $scope.submitForm = () ->
        $scope.errors = {}

        if !($scope.api_configuration.datafeed_configuration_details.revenue_calculation_pattern?)
          $scope.errors.revenue_calculation_pattern = "can't be blank"

        if Object.keys($scope.errors).length > 0 then return

        $scope.api_configuration.datafeed_configuration_details_attributes = $scope.api_configuration.datafeed_configuration_details
        ApiConfiguration.create(api_configuration: $scope.api_configuration).then (api_configuration) ->
          $scope.api_configuration = api_configuration
          $modalInstance.close()

      $scope.cancel = ->
        $modalInstance.close()
  ]
