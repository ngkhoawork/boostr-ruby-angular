@service.service 'ClientType',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/client_types/:id', { id: '@id' },
    update: {
      method: 'PUT'
      url: '/api/client_types/:id'
    }

  @all = ->
    deferred = $q.defer()
    resource.query {}, (client_types) ->
      deferred.resolve(client_types)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (client_type) ->
      deferred.resolve(client_type)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (client_type) ->
      deferred.resolve(client_type)
    deferred.promise

  @delete = (client_type) ->
    deferred = $q.defer()
    resource.delete { id: client_type.id }, ->
      deferred.resolve(client_type)
    deferred.promise

  return
]
