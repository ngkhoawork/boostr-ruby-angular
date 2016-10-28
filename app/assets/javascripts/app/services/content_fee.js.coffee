@service.service 'ContentFee',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->
  transformRequest = (original, headers) ->
    send = {}
    send.content_fee =
      budget: original.content_fee.budget
      content_fee_product_budgets_attributes: original.content_fee.content_fee_product_budgets
    angular.toJson(send)

  resource = $resource '/api/ios/:io_id/content_fees/:id', { io_id: '@io_id', id: '@id' },
    update:
      method: 'PUT'
      url: '/api/ios/:io_id/content_fees/:id'
      transformRequest: transformRequest

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (io) ->
      deferred.resolve(io)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (io) ->
      deferred.resolve(io)
    deferred.promise

  @delete = (params) ->
    deferred = $q.defer()
    resource.delete params, (io) ->
      deferred.resolve(io)
    deferred.promise

  return
]
