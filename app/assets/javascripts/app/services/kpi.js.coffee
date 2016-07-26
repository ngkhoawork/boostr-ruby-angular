@service.service 'KPI',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/kpis/'
  @all = ->
    deferred = $q.defer()
    resource.query {}, (status) ->
      deferred.resolve(status)
    deferred.promise

  return
]