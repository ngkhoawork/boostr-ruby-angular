@service.service 'Reminder',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  transformRequest = (original, headers) ->
    original.reminder.values_attributes = original.reminder.values
    angular.toJson(original)

#  resource = $resource ' /api/reminders/:id', { id: '@id' },
  resource = $resource '/api/remindable/:remindable_id/:remindable_type', { remindable_id: '@remindable_id', remindable_type: '@remindable_type', id: '@id' },
    save: {
      method: 'POST'
      url: '/api/reminders'
      transformRequest: transformRequest
    },
    update: {
      method: 'PUT'
      url: '/api/reminders/:id'
      transformRequest: transformRequest
    }

  currentReminder = undefined

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (reminders) ->
      deferred.resolve(reminders)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (reminder) ->
      deferred.resolve(reminder)
      $rootScope.$broadcast 'updated_reminders'
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (reminder) ->
      deferred.resolve(reminder)
      $rootScope.$broadcast 'updated_reminders'
    deferred.promise

  @get = (remindable_id, remindable_type) ->
    deferred = $q.defer()
    resource.get remindable_id: remindable_id, remindable_type: remindable_type, (reminder) ->
      deferred.resolve(reminder)
    deferred.promise

  @delete = (deletedReminder) ->
    deferred = $q.defer()
    resource.delete id: deletedReminder.id, () ->
      deferred.resolve()
      $rootScope.$broadcast 'updated_reminders'
    deferred.promise

  return
]


#@service.service 'ReminderResource',
#['$resource',
#($resource) ->
#
#  transformRequest = (original, headers) ->
#    original.reminder.values_attributes = original.reminder.values
#    angular.toJson(original)
#
#  resource = $resource '/api/reminders/:id', { id: '@id' },
#    save: {
#      method: 'POST'
#      url: '/api/deals'
#      transformRequest: transformRequest
#    },
#    update: {
#      method: 'PUT'
#      url: '/api/reminders/:id'
#      transformRequest: transformRequest
#    }
#
#  resource
#]
