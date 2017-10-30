@service.service 'PacingAlerts',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/dashboard/pacing_alerts'

  @get = (params) ->
    deferred = $q.defer()
    resource.get params, (data) ->
      deferred.resolve(data)
    , (error) ->
      deferred.reject(error)
    deferred.promise

  return
]
