@service.service 'Request',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  resource = $resource '/api/requests/:id', { id: '@id' },
    save: {
      method: 'POST'
      url: '/api/requests/:id'
    },
    update: {
      method: 'PUT'
      url: '/api/requests/:id'
    }

  @statuses = [
    'New',
    'Denied',
    'Completed'
  ]

  @request_types = [
    'Revenue',
    'Resource'
  ]

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (data) ->
      deferred.resolve(data)
    deferred.promise

  @get = (id) ->
    deferred = $q.defer()
    resource.get id: id, (data) ->
      deferred.resolve(data)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (data) ->
      $rootScope.$broadcast 'newRequest', data
      deferred.resolve(data)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (data) ->
      $rootScope.$broadcast 'newRequest', data
      deferred.resolve(data)
    deferred.promise

  @delete = (params) ->
    deferred = $q.defer()
    resource.delete { id: params.id }, (data) ->
      deferred.resolve(data)
    deferred.promise

  return
]
