@service.service 'IntegrationType',
  ['$resource', '$rootScope', '$q',
    ($resource, $rootScope, $q) ->

      resource = $resource '/api/integration_types/:id', {  },
        get: {
          isArray: true
        }

      @all = (params) ->
        deferred = $q.defer()
        resource.get params, (api_integrations) ->
          deferred.resolve(api_integrations)
        deferred.promise

      return
  ]
