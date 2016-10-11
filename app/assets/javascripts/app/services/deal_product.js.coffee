@service.service 'DealProduct',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->
  resource = $resource '/api/deals/:deal_id/deal_products/:id', { deal_id: '@deal_id', id: '@id' },
    update: {
      method: 'PUT'
      url: '/api/deals/:deal_id/deal_products/:id'
    }

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
