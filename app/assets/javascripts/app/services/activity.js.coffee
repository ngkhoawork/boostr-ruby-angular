@service.service 'Activity',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  @types = [
    {'name':'Initial Meeting', 'action':'had initial meeting with', 'icon':'/assets/icons/initial-meeting.svg'},
    {'name':'Pitch', 'action':'pitched to', 'icon':'/assets/icons/pitch.svg'},
    {'name':'Proposal', 'action':'sent proposal to', 'icon':'/assets/icons/proposal.svg'},
    {'name':'Feedback', 'action':'received feedback from', 'icon':'/assets/icons/feedback.svg'},
    {'name':'Agency Meeting', 'action':'had agency meeting with', 'icon':'/assets/icons/meeting.svg'},
    {'name':'Client Meeting', 'action':'had client meeting with', 'icon':'/assets/icons/meeting.svg'},
    {'name':'Entertainment', 'action':'had client entertainment with', 'icon':'/assets/icons/entertainment.svg'},
    {'name':'Campaign Review', 'action':'reviewed campaign with', 'icon':'/assets/icons/review.svg'},
    {'name':'QBR', 'action':'Quarterly Business Review with', 'icon':'/assets/icons/QBR.svg'}
  ]

  resource = $resource '/api/activities/:id', { id: '@id' },
    save: {
      method: 'POST'
      url: '/api/activities'
    },
    update: {
      method: 'PUT'
      url: '/api/activities/:id'
    }

  @$resource = resource

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
