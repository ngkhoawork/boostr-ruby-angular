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

  types = []

  @all = (params) ->
    deferred = $q.defer()
    if types.length == 0
      resource.query params, (activity_types) =>
        types = activity_types
        deferred.resolve(activity_types)
    else
      deferred.resolve(types)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (activity_type) ->
      deferred.resolve(activity_type)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (activity_type) ->
      deferred.resolve(activity_type)
      $rootScope.$broadcast 'updated_activity_types'
    deferred.promise

  @delete = (deletedActivityType) ->
    deferred = $q.defer()
    resource.delete id: deletedActivity.id, () ->
      deferred.resolve()
      $rootScope.$broadcast 'updated_activity_types'
    deferred.promise

  @get = (activity_type_id) ->
    deferred = $q.defer()
    resource.get id: activity_type_id, (activity_type) ->
      deferred.resolve(activity_type)
    deferred.promise
  
  return
]
