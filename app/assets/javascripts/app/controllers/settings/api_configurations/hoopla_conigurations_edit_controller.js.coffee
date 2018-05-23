@app.controller 'HooplaConfigurationsEditController',
  ['$window', '$scope', '$modalInstance', 'ApiConfiguration', 'api_configuration', 'IntegrationType'
    ($window, $scope, $modalInstance, ApiConfiguration, api_configuration, IntegrationType) ->

      init = ->
        $scope.formType = 'Edit'
        $scope.submitText = 'Update'
        $scope.connected = false
        $scope.loaded = false
        $scope.api_configuration = angular.copy api_configuration
        $scope.api_configuration.hoopla_details_attributes = {
          id: $scope.api_configuration.hoopla_details.id
          client_id: $scope.api_configuration.hoopla_details.client_id
          client_secret: $scope.api_configuration.hoopla_details.client_secret
        }
        onLoad()

      onLoad = -> 
        if $scope.api_configuration.hoopla_details.connected
          $scope.connected = true
        else
          $scope.connected = false

      $scope.submitForm = () ->
        ApiConfiguration.update(id: $scope.api_configuration.id, api_configuration: $scope.api_configuration).then (api_configuration) ->
          $scope.api_configuration = Object.assign({}, $scope.api_configuration, api_configuration)
          $scope.loaded = true
          onLoad()
          console.log 'api_configuration: ', api_configuration
          console.log '$scope.api_configuration: ', $scope.api_configuration
          console.log '$scope.connected: ', $scope.connected
          if $scope.connected then $modalInstance.close()

      $scope.cancel = -> $modalInstance.close()

      init()
  ]
