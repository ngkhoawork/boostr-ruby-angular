@service.service 'Stage',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  resource = $resource '/api/stages/:id', { id: '@id' },
    update: {
      method: 'PUT'
      url: '/api/stages/:id'
    }

  @all = ->
    deferred = $q.defer()
    resource.query {}, (stages) ->
      deferred.resolve(stages)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (stage) ->
      deferred.resolve(stage)
      $rootScope.$broadcast 'updated_stages'
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (stage) ->
      deferred.resolve(stage)
    deferred.promise

  return
]