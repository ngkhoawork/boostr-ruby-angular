@service.service 'KPI',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/kpis/'

  @all = ->
    deferred = $q.defer()
    resource.query {}, (users) ->
      deferred.resolve(users)
    deferred.promise

  return
]