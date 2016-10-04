@service.service 'CurrentUser',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->
  resource = $resource '/api/users/signed_in_user', {}

  @current_user = () ->
    deferred = $q.defer()
    current_user_collection.get (user) ->
      deferred.resolve(user)
    deferred.promise

  return resource
]
