@service.service 'Revenue',
['$resource',
($resource) ->

  resource = $resource '/api/revenue/:id', { id: '@id' }

  allRevenue = []

  @all = (callback) ->
    resource.query {}, (revenue) =>
      allRevenue = revenue
      callback(revenue)

  return
]