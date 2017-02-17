@service.service 'ApiConfiguration',
  ['$resource', '$rootScope', '$q',
    ($resource, $rootScope, $q) ->

      resource = $resource '/api/api_configurations/:id', { id: '@id' },
        update: {
          method: 'PUT'
          url: '/api/api_configurations/:id'
        }

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

      return
  ]
