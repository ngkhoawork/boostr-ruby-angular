@service.service 'Revenue',
['$resource',
($resource) ->

  resource = $resource '/api/revenue/:id', { id: '@id' }

  allRevenue = []

  @all = (callback) ->
    if allRevenue.length == 0
      resource.query {}, (revenue) =>
        allRevenue = revenue
        callback(revenue)
    else
      callback(allRevenue)

  return
]