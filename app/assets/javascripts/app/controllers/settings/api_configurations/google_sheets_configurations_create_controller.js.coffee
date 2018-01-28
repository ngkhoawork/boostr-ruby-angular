@app.controller 'GoogleSheetsConfigurationsCreateController',
  ['$window', '$scope', '$modalInstance', 'ApiConfiguration', 'IntegrationType'
  ($window, $scope, $modalInstance, ApiConfiguration, IntegrationType) ->

      $scope.formType = 'Create'
      $scope.submitText = 'Create'
      $scope.need_change_password = false
      ApiConfiguration.service_account_email().then (service_account_email) ->
        $scope.service_account_email = service_account_email.service_account_email
      $scope.api_configuration = {}
      $scope.api_configuration.google_sheets_details_attributes = {}
      $scope.api_configuration.switched_on = true
      $scope.api_configuration.integration_provider = 'Google Sheets'
      $scope.api_configuration.trigger_on_deal_percentage = 0

      $scope.submitForm = () ->
        ApiConfiguration.create(api_configuration: $scope.api_configuration).then (api_configuration) ->
          $scope.api_configuration = api_configuration
          $modalInstance.close()

      $scope.cancel = ->
        $modalInstance.close()
  ]
