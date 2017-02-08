@service.service 'Dashboard',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/dashboard'

  @get = (params) ->
    deferred = $q.defer()
    resource.get params, (team) ->
#    resource.get params, (team) ->
      deferred.resolve(team)
    deferred.promise

  return

]
