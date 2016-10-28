@service.service 'IOMember',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  transformRequest = (original, headers) ->
    original.io_member.values_attributes = original.io_member.values
    angular.toJson(original)

  resource = $resource '/api/ios/:io_id/io_members/:id', { io_id: '@io_id', id: '@id' },
    save: {
      method: 'POST'
      url: '/api/ios/:io_id/io_members'
      transformRequest: transformRequest
    },
    update: {
      method: 'PUT'
      url: '/api/ios/:io_id/io_members/:id'
      transformRequest: transformRequest
    }

  @all = (params) ->
    resource.query params, (io_member) ->
      deferred = $q.defer()
      deferred.resolve(io_member)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (io_member) ->
      deferred.resolve(io_member)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (io_member) ->
      deferred.resolve(io_member)
    deferred.promise

  @delete = (params) ->
    deferred = $q.defer()
    resource.delete { io_id: params.io_id, id: params.id }, (io) ->
      deferred.resolve(io)
    deferred.promise

  return
]
