@service.service 'Quota',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

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

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (deal) ->
      deferred.resolve(deal)
      $rootScope.$broadcast 'updated_quotas'
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (deal) ->
      deferred.resolve(deal)
      $rootScope.$broadcast 'updated_quotas'
    deferred.promise

  return
]