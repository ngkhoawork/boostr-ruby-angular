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
        delete_ssp:
          method: 'POST'
          url: 'api/api_configurations/:id/delete_ssp'
        update_ssp:
          method: 'POST'
          url: 'api/api_configurations/:id/update_ssp'

      @all = (params) ->
        deferred = $q.defer()
        resource.get params, (api_integrations) ->
          deferred.resolve(api_integrations)
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

      return
  ]
