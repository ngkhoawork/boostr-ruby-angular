@service.service 'DealProduct',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->
  transformRequest = (original, headers) ->
    send = {}
    send.deal_product =
      budget_loc: original.deal_product.budget_loc
      deal_product_budgets_attributes: original.deal_product.deal_product_budgets
      product_id: original.deal_product.product_id
    angular.toJson(send)

  resource = $resource '/api/deals/:deal_id/deal_products/:id', { deal_id: '@deal_id', id: '@id' },
    update:
      method: 'PUT'
      url: '/api/deals/:deal_id/deal_products/:id'
      transformRequest: transformRequest
    save:
      method: 'POST'
      transformRequest: transformRequest

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (deal) ->
      deferred.resolve(deal)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (deal) ->
      deferred.resolve(deal)
    deferred.promise

  @delete = (params) ->
    deferred = $q.defer()
    resource.delete params, (deal) ->
      deferred.resolve(deal)
    deferred.promise

  return
]
