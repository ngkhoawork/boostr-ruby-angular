@service.service 'Stage',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/stages/:id', { id: '@id' }

  @all = ->
    deferred = $q.defer()
    resource.query {}, (stages) ->
      allStages = stages
      deferred.resolve(stages)
    deferred.promise

  return
]