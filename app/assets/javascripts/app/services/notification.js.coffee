@service.service 'Notification',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  resource = $resource '/api/notifications/:id', { id: '@id' },
    update: {
      method: 'PUT'
      url: '/api/notifications/:id'
    }

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (notifications) ->
      deferred.resolve(notifications)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (notification) ->
      deferred.resolve(notification)
      $rootScope.$broadcast 'updated_notifications'
    deferred.promise

  return
]
