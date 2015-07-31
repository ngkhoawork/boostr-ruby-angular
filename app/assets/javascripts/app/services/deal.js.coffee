@service.service 'Deal',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  resource = $resource '/api/deals/:id', { id: '@id' }

  allDeals = []

  @all = ->
    deferred = $q.defer()
    if allDeals.length == 0
      resource.query {}, (deals) =>
        allDeals = deals
        deferred.resolve(deals)
    else
      deferred.resolve(allDeals)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (deal) ->
      allDeals.push(deal)
      deferred.resolve(deal)
      $rootScope.$broadcast 'updated_deals'
    deferred.promise

  return
]