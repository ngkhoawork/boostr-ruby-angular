@app.controller 'GoogleSheetsConfigurationsEditController',
  ['$window', '$scope', '$modalInstance', 'ApiConfiguration', 'api_configuration', 'IntegrationType'
    ($window, $scope, $modalInstance, ApiConfiguration, api_configuration, IntegrationType) ->

      $scope.formType = 'Edit'
      $scope.submitText = 'Update'
      $scope.need_change_password = false
      ApiConfiguration.service_account_email().then (service_account_email) ->
        $scope.service_account_email = service_account_email.service_account_email
      $scope.api_configuration = api_configuration
      $scope.api_configuration.google_sheets_details_attributes = api_configuration.google_sheets_details

      $scope.submitForm = () ->
        ApiConfiguration.update(id: $scope.api_configuration.id, api_configuration: $scope.api_configuration).then (api_configuration) ->
          $scope.api_configuration = api_configuration
          $modalInstance.close()

      $scope.cancel = ->
        $modalInstance.close()
  ]
