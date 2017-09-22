@service.service 'ActivityType',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  resource = $resource '/api/activity_types/:id', { id: '@id' },
    get: {
      method: 'GET',
      cache: true
    },
    save: {
      method: 'POST'
      url: '/api/activity_types'
    },
    update: {
      method: 'PUT'
      url: '/api/activity_types/:id'
    }
    updatePositions:
      method: 'PUT'
      url: '/api/activity_types/update_positions'
      isArray: true

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (activity_types) ->
      deferred.resolve(activity_types)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (activity_type) ->
      deferred.resolve(activity_type)
      $rootScope.$broadcast 'updated_activity_types'
    deferred.promise

  @update = (params, noBroadcast) ->
    deferred = $q.defer()
    resource.update params, (activity_type) ->
      deferred.resolve(activity_type)
      if !noBroadcast
        $rootScope.$broadcast 'updated_activity_types'
    deferred.promise

  @delete = (activityType) ->
    deferred = $q.defer()
    resource.delete id: activityType.id, () ->
      deferred.resolve()
      $rootScope.$broadcast 'updated_activity_types'
    deferred.promise

  @get = (activity_type_id) ->
    deferred = $q.defer()
    resource.get id: activity_type_id, (activity_type) ->
      deferred.resolve(activity_type)
    deferred.promise

  @updatePositions = (positions) -> resource.updatePositions(positions).$promise

  return
]
