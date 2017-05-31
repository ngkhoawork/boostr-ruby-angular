@service.service 'ClientContact',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  transformRequest = (original, headers) ->
#          original.client_contact.values_attributes = original.client_contact.values
    angular.toJson(original)

  resource = $resource '/api/clients/:client_id/client_contacts/:id', { client_id: '@client_id', id: '@id' },
    save: {
      method: 'POST'
      transformRequest: transformRequest
    },
    update: {
      method: 'PUT'
      transformRequest: transformRequest
    }
    update_status: {
      method: 'PUT'
    }

  @all = (params) ->
    resource.query params, (client_contact) ->
      deferred = $q.defer()
      deferred.resolve(client_contact)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (client_contact) ->
      deferred.resolve(client_contact)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (client_contact) ->
      deferred.resolve(client_contact)
    deferred.promise

  @delete = (params) ->
    deferred = $q.defer()
    resource.delete { client_id: params.client_id, id: params.id }, (client) ->
      deferred.resolve(client)
    deferred.promise

  return resource
]
