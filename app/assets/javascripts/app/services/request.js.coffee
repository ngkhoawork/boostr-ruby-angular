@service.service 'Request',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  # transformRequest = (original, headers) ->
  #   original.deal_member.values_attributes = original.deal_member.values
  #   angular.toJson(original)

  resource = $resource '/api/requests/:id', { id: '@id' },
    save: {
      method: 'POST'
      url: '/api/requests/:id'
      # transformRequest: transformRequest
    },
    update: {
      method: 'PUT'
      url: '/api/requests/:id'
      # transformRequest: transformRequest
    }

  @all = (params) ->
    resource.query params, (data) ->
      deferred = $q.defer()
      deferred.resolve(data)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (data) ->
      deferred.resolve(data)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (data) ->
      deferred.resolve(data)
    deferred.promise

  @delete = (params) ->
    deferred = $q.defer()
    resource.delete { id: params.id }, (data) ->
      deferred.resolve(data)
    deferred.promise

  return
]
