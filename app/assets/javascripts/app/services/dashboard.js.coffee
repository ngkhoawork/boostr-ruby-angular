@service.service 'Dashboard',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/dashboard'

  @get = (params) ->
    deferred = $q.defer()
    resource.get params, (team) ->
      deferred.resolve(team)
    , (error) ->
      deferred.reject(error)
    deferred.promise

  return

]
