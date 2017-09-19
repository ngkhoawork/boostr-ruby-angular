@app.controller 'DfpApiConfigurationsEditController',
  ['$scope', '$modalInstance', 'ApiConfiguration', 'api_configuration'
    ($scope, $modalInstance, ApiConfiguration, api_configuration) ->

      $scope.formType = 'Edit'
      $scope.submitText = 'Update'

      $scope.api_configuration = api_configuration

      $scope.cpm_budget_adjustment = $scope.api_configuration.cpm_budget_adjustment
      $scope.cumulative_dfp_report_query = $scope.api_configuration.cumulative_dfp_report_query
      $scope.monthly_dfp_report_query = $scope.api_configuration.monthly_dfp_report_query
      $scope.api_configuration.cpm_budget_adjustment_attributes = $scope.cpm_budget_adjustment
      $scope.api_configuration.dfp_report_queries_attributes = [$scope.cumulative_dfp_report_query, $scope.monthly_dfp_report_query]
      $scope.weekdays = moment.weekdays()
      $scope.monthDays = [1..31]
      $scope.date_range_types = [
        {type: 'last_month', name: 'Last Month'},
        {type: 'last_six_month', name: 'Last 6 Month'}
      ]
      $scope.submitForm = () ->
        ApiConfiguration.update(id: $scope.api_configuration.id, api_configuration: $scope.api_configuration).then (api_configuration) ->
          $scope.api_configuration = api_configuration
          $modalInstance.close()

      $scope.cancel = ->
        $modalInstance.close()
  ]