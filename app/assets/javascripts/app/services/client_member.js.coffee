@service.service 'ClientMember',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  resource = $resource '/api/clients/:client_id/client_members/:id', { client_id: '@client_id', id: '@id' },
    update: {
      method: 'PUT'
      url: '/api/clients/:client_id/client_members/:id'
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

  @roles = () ->
    [
      'Can Edit'
      'Can View'
      'Owner'
    ]
  return
]
