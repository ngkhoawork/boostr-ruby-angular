@service.service 'DealProductBudget',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  resource = $resource '/api/deal_product_budgets/:id', { id: '@id' },
    update: {
        method: 'PUT'
        url: '/api/deal_product_budgets/:id'
      }

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (deal) ->
      deferred.resolve(deal)
    deferred.promise

  return
]
