@service.service 'User',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/users/:id', { id: '@id' },
    invite: {
      method: 'POST'
      url: '/api/users/invitation'
    }

  allUsers = []

  @all = (callback) ->
    deferred = $q.defer()
    if allUsers.length == 0
      resource.query {}, (users) =>
        allUsers = users
        deferred.resolve(users)
    else
      deferred.resolve(allUsers)
    deferred.promise

  @invite = (params) ->
    deferred = $q.defer()
    resource.invite params, (user) ->
      allUsers.push(user)
      deferred.resolve(user)
    deferred.promise

  return
]
