@service.service 'User',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  resource = $resource '/api/users/:id', { id: '@id' },
    invite: {
      method: 'POST'
      url: '/api/users/invitation'
    }
    update: {
      method: 'PUT'
      url: '/api/users/:id'
    }

  allUsers = []
  currentUser = undefined

  @all = (force = false) ->
    deferred = $q.defer()
    if allUsers.length == 0 || force
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

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (user) ->
      _.each allUsers, (existingUser, i) ->
        if(existingUser.id == user.id)
          allUsers[i] = user
      deferred.resolve(user)
    deferred.promise

  @get = () ->
    currentUser

  @set = (user_id) =>
    currentUser = _.find allUsers, (user) ->
      return parseInt(user_id) == user.id
    $rootScope.$broadcast 'updated_current_user'

  return
]
