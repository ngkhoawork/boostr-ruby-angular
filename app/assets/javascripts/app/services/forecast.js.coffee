@service.service 'Forecast',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/forecasts/:id', { id: '@id' },
    query: {
      method: 'GET'
      url: '/api/forecasts'
      isArray: false
    }

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (teams) ->
      deferred.resolve(teams)
    deferred.promise

  @get = (params) ->
    deferred = $q.defer()
    resource.get params, (team) ->
      deferred.resolve(team)
    deferred.promise

  return

]
