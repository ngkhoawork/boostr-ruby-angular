@service.service 'DealContact',
['$resource', '$q',
($resource, $q) ->

  transformRequest = (original, headers) ->
    original.deal_contact.role = null if original.deal_contact.role == undefined
    angular.toJson(original)

  resource = $resource 'api/deals/:deal_id/deal_contacts/:id', { deal_id: '@deal_id', id: '@id' },
    update:
      method: 'PUT'
      transformRequest: transformRequest
    delete:
      method: 'DELETE'

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (data) ->
      deferred.resolve(data)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save(
      params,
      (data) ->
        deferred.resolve(data)
      (resp) ->
        deferred.reject(resp)
    )
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update(
      params,
      (data) ->
        deferred.resolve(data)
      (resp) ->
        deferred.reject(resp)
    )
    deferred.promise

  @delete = (params) ->
    deferred = $q.defer()
    resource.delete params, () ->
      deferred.resolve()
    deferred.promise

  return
]
