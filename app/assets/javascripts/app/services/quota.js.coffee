@service.service 'Quota',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/quotas/:id', { id: '@id' }

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (time_periods) ->
      deferred.resolve(time_periods)
    deferred.promise

  return
]