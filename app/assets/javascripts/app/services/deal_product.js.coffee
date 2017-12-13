@service.service 'DealProduct',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->
  transformRequest = (original, headers) ->
    send = {}
    send.deal_product =
      budget_loc: original.deal_product.budget_loc
      deal_product_budgets_attributes: original.deal_product.deal_product_budgets
      deal_product_cf_attributes: original.deal_product.deal_product_cf
      product_id: original.deal_product.product_id
      ssp_id: original.deal_product.ssp_id
      pmp_type: original.deal_product.pmp_type
      ssp_deal_id: original.deal_product.ssp_deal_id
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
    resource.delete(
      params,
      (data) ->
        deferred.resolve(data)
      (resp) ->
        deferred.reject(resp)
    )
    deferred.promise

  return
]
