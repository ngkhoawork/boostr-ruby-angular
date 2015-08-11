@service.service 'DealProduct',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  resource = $resource '/api/deal_products/:id', { id: '@id' }

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (deal) ->
      deferred.resolve(deal)
    deferred.promise

  return
]
