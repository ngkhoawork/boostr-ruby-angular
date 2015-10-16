@service.service 'ClientMember',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  transformRequest = (original, headers) ->
    original.client_member.values_attributes = original.client_member.values
    angular.toJson(original)

  resource = $resource '/api/clients/:client_id/client_members/:id', { client_id: '@client_id', id: '@id' },
    save: {
      method: 'POST'
      url: '/api/clients/:client_id/client_members/'
      transformRequest: transformRequest
    },
    update: {
      method: 'PUT'
      url: '/api/clients/:client_id/client_members/:id'
      transformRequest: transformRequest
    }

  @all = (params, callback) ->
    resource.query params, (client_member) ->
      callback(client_member)

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (client_member) ->
      deferred.resolve(client_member)
      $rootScope.$broadcast 'updated_client_members'
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (client_member) ->
      deferred.resolve(client_member)
      $rootScope.$broadcast 'updated_client_members'
    deferred.promise

  return
]
