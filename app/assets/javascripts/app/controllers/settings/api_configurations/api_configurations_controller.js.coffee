@app.controller 'ApiConfigurationsController',
  ['$scope', '$modal', 'ApiConfiguration',
    ($scope, $modal, ApiConfiguration) ->

      $scope.init = () ->
        $scope.api_configurations = {}
        ApiConfiguration.all().then (api_configurations) ->
          $scope.api_configurations = api_configurations.api_configurations

      $scope.editModal = (api_configuration) ->
        $scope.modalInstance = $modal.open
          templateUrl: 'modals/api_configuration_form.html'
          size: 'lg'
          controller: 'ApiConfigurationsEditController'
          backdrop: 'static'
          keyboard: false
          resolve:
            api_configuration: ->
              api_configuration

      $scope.createModal = ->
        $scope.modalInstance = $modal.open
          templateUrl: 'modals/api_configuration_form.html'
          size: 'lg'
          controller: 'ApiConfigurationsCreateController'
          backdrop: 'static'
          keyboard: false

      $scope.delete = (api_configuration) ->
        if confirm('Are you sure you want to delete "' +  api_configuration.integration_type + '"?')
          ApiConfiguration.delete api_configuration, ->
            $location.path('/settings/api_configurations')

      $scope.$on 'updated_api_integrations', ->
        $scope.init()

      $scope.init()
  ]