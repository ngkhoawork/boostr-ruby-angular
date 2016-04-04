@service.service 'Activity',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  resource = $resource '/api/activities/:id', { id: '@id' },
    save: {
      method: 'POST'
      url: '/api/activities'
    },
    update: {
      method: 'PUT'
      url: '/api/activities/:id'
    }

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (activities) ->
      deferred.resolve(activities)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (activity) ->
      deferred.resolve(activity)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (activity) ->
      deferred.resolve(activity)
      $rootScope.$broadcast 'updated_activities'
    deferred.promise

  @delete = (deletedActivity) ->
    deferred = $q.defer()
    resource.delete id: deletedActivity.id, () ->
      deferred.resolve()
      $rootScope.$broadcast 'updated_activities'
    deferred.promise

  @get = (activity_id) ->
    deferred = $q.defer()
    resource.get id: activity_id, (activity) ->
      deferred.resolve(activity)
    deferred.promise

  return
]
