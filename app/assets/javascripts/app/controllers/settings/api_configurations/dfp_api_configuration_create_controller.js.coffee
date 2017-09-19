@app.controller 'DfpApiConfigurationsCreateController',
  ['$scope', '$modalInstance', 'ApiConfiguration', 'IntegrationType', 'CurrentUser'
    ($scope, $modalInstance, ApiConfiguration, IntegrationType, Company) ->

      $scope.formType = 'Create'
      $scope.submitText = 'Create'

      $scope.cpm_budget_adjustment = {}
      $scope.api_configuration = {}
      $scope.cumulative_dfp_report_query = { report_type: 'cumulative' }
      $scope.monthly_dfp_report_query = { report_type: 'monthly' }
      $scope.api_configuration.cpm_budget_adjustment_attributes = $scope.cpm_budget_adjustment
      $scope.api_configuration.dfp_report_queries_attributes = [$scope.cumulative_dfp_report_query, $scope.monthly_dfp_report_query]
      $scope.weekdays = moment.weekdays()
      $scope.monthDays = [1..31]

      $scope.date_range_types = [
        {type: 'last_month', name: 'Last Month'},
        {type: 'last_six_month', name: 'Last 6 Month'}
      ]

      set_defaults = ->
        $scope.api_configuration.integration_provider = 'DFP'
        $scope.api_configuration.switched_on = true

      set_defaults()

      $scope.submitForm = () ->
        ApiConfiguration.create(api_configuration: $scope.api_configuration).then (api_configuration) ->
          $scope.api_configuration = api_configuration
          $modalInstance.close()

      $scope.cancel = ->
        $modalInstance.close()
  ]