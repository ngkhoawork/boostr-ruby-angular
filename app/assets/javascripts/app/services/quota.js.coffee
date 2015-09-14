@service.service 'Quota',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/quotas/:id', { id: '@id' },
    update: {
      method: 'PUT'
      url: '/api/quotas/:id'
    }

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (time_periods) ->
      deferred.resolve(time_periods)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (deal) ->
      deferred.resolve(deal)
    deferred.promise

  return
]