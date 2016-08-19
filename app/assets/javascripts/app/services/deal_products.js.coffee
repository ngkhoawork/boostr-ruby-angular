@service.service 'DealProduct',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  resource = $resource '/api/deal_products/:id', { id: '@id' },
    update: {
        method: 'PUT'
        url: '/api/deal_products/:id'
      }
  resource_collection = $resource '/api/deal_products/', {  },
    update: {
      method: 'PUT'
      url: '/api/deal_products/update_total_budget'
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

  @update_total_budget = (params) ->
    deferred = $q.defer()
    resource_collection.update params, (deal) ->
      deferred.resolve(deal)
    deferred.promise

  @delete = (params) ->
    deferred = $q.defer()
    resource.delete params, (deal) ->
      deferred.resolve(deal)
    deferred.promise

  return
]
