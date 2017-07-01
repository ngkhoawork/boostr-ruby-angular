@app.controller 'ApiConfigurationsController',
  ['$window', '$scope', '$modal', 'ApiConfiguration', 'IntegrationType', 'AsanaConnect'
    ($window, $scope, $modal, ApiConfiguration, IntegrationType, AsanaConnect) ->
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
              update: { templateUrl: 'modals/operative_datafeed_configuration_form.html', controller: 'DataFeedConfigurationsCreateController' },
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

      $scope.init = () ->
        $scope.api_configurations = {}
        ApiConfiguration.all().then (api_configurations) ->
          $scope.api_configurations = api_configurations.api_configurations
        IntegrationType.all().then (types) ->
          $scope.integration_types = types

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

      $scope.createModal = ->
        selectControllerTemplate = selectMapping($scope.current_integration)
        $scope.modalInstance = $modal.open
          templateUrl: selectControllerTemplate.actions.create.templateUrl
          size: 'lg'
          controller: selectControllerTemplate.actions.create.controller
          backdrop: 'static'
          keyboard: false

      $scope.linkAsana = ->
        AsanaConnect.get().$promise.then (connect_data) ->
          $window.location.href = connect_data.url

      $scope.delete = (api_configuration) ->
        if confirm('Are you sure you want to delete "' +  api_configuration.integration_type + '"?')
          ApiConfiguration.delete api_configuration, ->
            $location.path('/settings/api_configurations')

      $scope.$on 'updated_api_integrations', ->
        $scope.init()

      $scope.init()
  ]
