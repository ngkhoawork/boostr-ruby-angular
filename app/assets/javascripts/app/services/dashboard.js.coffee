@service.service 'Dashboard',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/dashboard'

  @get = ->
    deferred = $q.defer()
    resource.get {}, (team) ->
      deferred.resolve(team)
    deferred.promise

  return

]
