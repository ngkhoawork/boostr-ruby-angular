@service.service 'User',
['$resource',
($resource) ->

  resource = $resource '/api/users/:id', { id: '@id' }

  allUsers = []

  @all = (callback) ->
    if allUsers.length == 0
      resource.query {}, (users) =>
        allUsers = users
        callback(users)
    else
      callback(allUsers)

  return
]
