@service.service 'ContentFee',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->
  transformRequest = (original, headers) ->
    send = {}
    send.content_fee =
      budget_loc: original.content_fee.budget_loc
      content_fee_product_budgets_attributes: original.content_fee.content_fee_product_budgets
      io_id: original.content_fee.io_id
      product_id: original.content_fee.product_id
      custom_field_attributes: original.content_fee.custom_field
    angular.toJson(send)

  resource = $resource '/api/ios/:io_id/content_fees/:id', { io_id: '@io_id', id: '@id' },
    update:
      method: 'PUT'
      url: '/api/ios/:io_id/content_fees/:id'
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
