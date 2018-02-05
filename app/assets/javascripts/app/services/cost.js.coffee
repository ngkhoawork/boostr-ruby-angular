@service.service 'Cost',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->
  transformRequest = (original, headers) ->
    send = {}
    send.cost =
      budget_loc: original.cost.budget_loc
      cost_monthly_amounts_attributes: original.cost.cost_monthly_amounts
      io_id: original.cost.io_id
      product_id: original.cost.product_id
    angular.toJson(send)

  resource = $resource '/api/ios/:io_id/costs/:id', { io_id: '@io_id', id: '@id' },
    update:
      method: 'PUT'
      url: '/api/ios/:io_id/costs/:id'
      transformRequest: transformRequest
    save:
      method: 'POST'
      transformRequest: transformRequest

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
    resource.delete params, (io) ->
      deferred.resolve(io)
    deferred.promise

  return
]
