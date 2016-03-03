@service.service 'Revenue',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/revenue/:id', { id: '@id' }

  allRevenue = []

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (revenue) =>
      allRevenue = revenue
      deferred.resolve(revenue)
    deferred.promise

  return
]