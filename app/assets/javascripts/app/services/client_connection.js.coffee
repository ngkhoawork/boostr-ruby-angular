@service.service 'ClientConnection',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  transformRequest = (original, headers) ->
#    original.client_connection.values_attributes = original.client_connection.values
    angular.toJson(original)

  resource = $resource '/api/client_connections/:id', { client_id: '@client_id', id: '@id' },
    save: {
      method: 'POST'
      url: '/api/client_connections'
      transformRequest: transformRequest
    },
    update: {
      method: 'PUT'
      url: '/api/client_connections/:id'
      transformRequest: transformRequest
    }

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (client_connection) ->
      deferred.resolve(client_connection)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (client_connection) ->
      deferred.resolve(client_connection)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (client_connection) ->
      deferred.resolve(client_connection)
    deferred.promise

  @delete = (params) ->
    deferred = $q.defer()
    resource.delete { client_id: params.client_id, id: params.id }, (client) ->
      deferred.resolve(client)
    deferred.promise

  return
]
