@service.service 'Revenue',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/revenue/:id', { id: '@id' },
    get:
      method: 'GET'
      url: '/api/revenue'
      isArray: true

  allRevenue = []

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (revenue) =>
      allRevenue = revenue
      deferred.resolve(revenue)
    deferred.promise

  @get = (params) ->
    deferred = $q.defer()
    resource.get params, (revenue) ->
      deferred.resolve(revenue)
    deferred.promise

  return
]
