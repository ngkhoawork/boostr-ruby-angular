@service.service 'WeightedPipeline',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/weighted_pipelines/:id', { id: '@id' },
    get:
      method: 'GET'
      url: '/api/weighted_pipelines/:id'
      isArray: true

  @get = (params) ->
    deferred = $q.defer()
    resource.get params, (team) ->
      deferred.resolve(team)
    deferred.promise

  return

]
