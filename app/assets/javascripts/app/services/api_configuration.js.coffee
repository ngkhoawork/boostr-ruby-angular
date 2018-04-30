@service.service 'ApiConfiguration',
  ['$resource', '$rootScope', '$q',
    ($resource, $rootScope, $q) ->

      resource = $resource '/api/api_configurations/:id', { id: '@id' },
        metadata:
          method: 'GET'
          url: 'api/api_configurations/metadata'
          isArray: false
        update:
          method: 'PUT'
          url: '/api/api_configurations/:id'
        service_account_email:
          method: 'GET'
          url: 'api/api_configurations/service_account_email'
        ssp:
          method: 'GET'
          url: 'api/api_configurations/ssp_credentials'
        ssp_providers:
          method: 'GET'
          url: 'api/api_configurations/ssp_providers'
          isArray: true
        delete_ssp:
          method: 'POST'
          url: 'api/api_configurations/:id/delete_ssp'
        update_ssp:
          method: 'POST'
          url: 'api/api_configurations/:id/update_ssp',
        workflowable_actions:
          method: 'GET'
          url: 'api/api_configurations/workflowable_actions'
          isArray: true

      @all = (params) ->
        deferred = $q.defer()
        resource.get params, (api_integrations) ->
          deferred.resolve(api_integrations)
        deferred.promise

      @ssp_providers = (params) ->
        deferred = $q.defer()
        resource.ssp_providers params, (ssp_providers) ->
          deferred.resolve(ssp_providers)
        deferred.promise

      @create = (params) ->
        deferred = $q.defer()
        resource.save params, (api_integration) ->
          deferred.resolve(api_integration)
          $rootScope.$broadcast 'updated_api_integrations'
        deferred.promise

      @update = (params) ->
        deferred = $q.defer()
        resource.update params, (api_integration) ->
          deferred.resolve(api_integration)
          $rootScope.$broadcast 'updated_api_integrations'
        deferred.promise

      @delete = (api_configuration) ->
        deferred = $q.defer()
        resource.delete id: api_configuration.id, () ->
          deferred.resolve()
          $rootScope.$broadcast 'updated_api_integrations'
        deferred.promise

      @metadata = (params) ->
        deferred = $q.defer()
        resource.metadata params, (data) ->
          deferred.resolve(data)
        deferred.promise

      @service_account_email = (params) ->
        deferred = $q.defer()
        resource.service_account_email params, (data) ->
          deferred.resolve(data)
        deferred.promise

      @ssp_credentials = (params) ->
        deferred = $q.defer()
        resource.ssp params, (data) ->
          deferred.resolve(data)
        deferred.promise

      @delete_ssp = (params) ->
        deferred = $q.defer()
        resource.delete_ssp params, (data) ->
          deferred.resolve(data)
          $rootScope.$broadcast 'updated_api_integrations'
        deferred.promise

      @update_ssp = (params) ->
        deferred = $q.defer()
        resource.update_ssp params, (data) ->
          deferred.resolve(data)
          $rootScope.$broadcast 'updated_api_integrations'
        deferred.promise

      @workflowable_actions = ->
        resource.workflowable_actions().$promise

      return
  ]
