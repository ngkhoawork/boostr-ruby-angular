@app.controller 'HooplaConfigurationsCreateController',
  ['$window', '$scope', '$modalInstance', 'ApiConfiguration', 'IntegrationType'
  ($window, $scope, $modalInstance, ApiConfiguration, IntegrationType) ->

    init = ->
      $scope.formType = 'Create'
      $scope.submitText = 'Connect'
      $scope.connected = false
      $scope.loaded = false
      $scope.api_configuration = {}
      $scope.api_configuration.integration_provider = 'Hoopla'

    onLoad = ->
      $scope.api_configuration.hoopla_details_attributes.id = $scope.api_configuration.hoopla_details.id
      if $scope.api_configuration.hoopla_details.connected
        $scope.submitText = 'Create'
        $scope.connected = true
        $scope.api_configuration.switched_on = true
      else
        $scope.submitText = 'Connect'
        $scope.connected = false
        $scope.api_configuration.switched_on = false

    $scope.submitForm = () ->
      if !$scope.api_configuration.id
        ApiConfiguration
          .create(api_configuration: $scope.api_configuration)
          .then (api_configuration) ->
            $scope.api_configuration = Object.assign({}, $scope.api_configuration, api_configuration)
            $scope.loaded = true
            onLoad()
      else if $scope.api_configuration.id && !$scope.api_configuration.hoopla_details.connected
        ApiConfiguration
          .update(id: $scope.api_configuration.id, api_configuration: $scope.api_configuration)
          .then (api_configuration) ->
            $scope.api_configuration = Object.assign({}, $scope.api_configuration, api_configuration)
            onLoad()
      else if $scope.api_configuration.hoopla_details.connected
        ApiConfiguration
          .update(id: $scope.api_configuration.id, api_configuration: $scope.api_configuration)
          .then (api_configuration) -> $modalInstance.close()

    $scope.cancel = -> $modalInstance.close()

    init()
  ]
