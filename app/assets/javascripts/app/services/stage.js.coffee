@service.service 'Stage',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/stages/:id', { id: '@id' },
    update: {
      method: 'PUT'
      url: '/api/stages/:id'
    }

  @all = ->
    deferred = $q.defer()
    resource.query {}, (stages) ->
      allStages = stages
      deferred.resolve(stages)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (stage) ->
      deferred.resolve(stage)
    deferred.promise

  return
]