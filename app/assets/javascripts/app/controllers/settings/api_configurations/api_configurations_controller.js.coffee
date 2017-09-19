@app.controller 'ApiConfigurationsController',
  ['$window', '$scope', '$modal', 'ApiConfiguration', 'IntegrationType', 'DfpImportService'
    ($window, $scope, $modal, ApiConfiguration, IntegrationType, DfpImportService) ->
      mappings = {
        providers: {
          dfp: {
            actions: {
              create: { templateUrl: 'modals/dfp_api_configuration_form.html', controller: 'DfpApiConfigurationsCreateController' },
              update: { templateUrl: 'modals/dfp_api_configuration_form.html', controller: 'DfpApiConfigurationsEditController' }
            }
          },
          operative: {
            actions: {
              create: { templateUrl: 'modals/operative_api_configuration_form.html', controller: 'OperativeApiConfigurationsCreateController' },
              update: { templateUrl: 'modals/operative_api_configuration_form.html', controller: 'OperativeApiConfigurationsEditController' }
            }
          },
          operative_datafeed: {
            actions: {
              create: { templateUrl: 'modals/operative_datafeed_configuration_form.html', controller: 'DataFeedConfigurationsCreateController' },
              update: { templateUrl: 'modals/operative_datafeed_configuration_form.html', controller: 'DataFeedConfigurationsEditController' },
            }
          },
          asana_connect: {
            actions: {
              create: { templateUrl: 'modals/asana_connect_configuration_form.html', controller: 'AsanaConnectConfigurationsCreateController' },
              update: { templateUrl: 'modals/asana_connect_configuration_form.html', controller: 'AsanaConnectConfigurationsEditController' }
            }
          }
        }
      }

      $scope.controller_config = {}
      $scope.integration_types = []
      $scope.current_integration = 'operative'

      $scope.selectIntegrationProvider = (provider) ->
        $scope.current_integration = provider
        $scope.createModal()

      selectMapping = (provider) ->
        switch provider
          when 'DFP'
            mappings.providers.dfp
          when 'operative'
            mappings.providers.operative
          when 'Operative Datafeed'
            mappings.providers.operative_datafeed
          when 'Asana Connect'
            mappings.providers.asana_connect

      init = () ->
        $scope.api_configurations = {}
        ApiConfiguration.all().then (api_configurations) ->
          $scope.api_configurations = api_configurations.api_configurations
          $scope.dfp_turned_on = false
          dfp_config = _.find($scope.api_configurations, (item) ->
            if item.integration_provider == 'DFP'
              return item)
          if dfp_config and dfp_config.switched_on
            $scope.dfp_turned_on = true
            $scope.dfp_config_id = dfp_config.id
        IntegrationType.all().then (types) ->
          $scope.integration_types = types

      $scope.dfp_monthly_import = ->
        DfpImportService.import(api_configuration_id: $scope.dfp_config_id, report_type: 'monthly').then (resp) ->
          $scope.showInfoModal(resp.message)

      $scope.dfp_cumulative_import = ->
        DfpImportService.import(api_configuration_id: $scope.dfp_config_id, report_type: 'cumulative').then (resp) ->
          $scope.showInfoModal(resp.message)

      $scope.editModal = (api_configuration) ->
        selectControllerTemplate = selectMapping(api_configuration.integration_provider)
        $scope.modalInstance = $modal.open
          templateUrl: selectControllerTemplate.actions.update.templateUrl
          size: 'lg'
          controller: selectControllerTemplate.actions.update.controller
          backdrop: 'static'
          keyboard: false
          resolve:
            api_configuration: ->
              api_configuration

      $scope.showInfoModal = (message) ->
        $scope.modalInstance = $modal.open
          templateUrl: 'modals/dfp_info.html'
          size: 'md'
          controller: 'DfpImportInfoController'
          backdrop: 'static'
          keyboard: true
          resolve:
            message: -> message

      $scope.createModal = ->
        selectControllerTemplate = selectMapping($scope.current_integration)
        $scope.modalInstance = $modal.open
          templateUrl: selectControllerTemplate.actions.create.templateUrl
          size: 'lg'
          controller: selectControllerTemplate.actions.create.controller
          backdrop: 'static'
          keyboard: false

      $scope.delete = (api_configuration) ->
        if confirm('Are you sure you want to delete "' +  api_configuration.integration_type + '"?')
          ApiConfiguration.delete api_configuration, ->
            $location.path('/settings/api_configurations')

      $scope.$on 'updated_api_integrations', ->
        init()

      init()
  ]
