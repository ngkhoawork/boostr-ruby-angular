@service.service 'Team',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  transformRequest = (original, headers) ->
    original.team.parent_id = null if original.team.parent_id == undefined
    original.team.sales_process_id = null if original.team.sales_process_id == undefined
    angular.toJson(original)

  resource = $resource '/api/teams/:id', { id: '@id' },
    update: {
      method: 'PUT'
      url: '/api/teams/:id'
      transformRequest: transformRequest
    }
    by_user: {
      method: 'GET'
      url: '/api/teams/by_user/:id'
      isArray: true
    }
    members: {
      method: 'GET'
      url: '/api/teams/:id/members'
    }

  collection = $resource '/api/teams/all_members'

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (teams) ->
      deferred.resolve(teams)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params,
      (team) ->
        deferred.resolve(team)
        $rootScope.$broadcast 'updated_teams'
      (resp) ->
        deferred.reject(resp)
    deferred.promise

  @members = (team_id) ->
    deferred = $q.defer()
    resource.members id: team_id, (members) ->
      deferred.resolve(members)
    deferred.promise

  @all_members = (params) ->
    deferred = $q.defer()
    collection.query params, (members) ->
      deferred.resolve(members)
    deferred.promise

  @get = (team_id) ->
    deferred = $q.defer()
    resource.get id: team_id, (team) ->
      deferred.resolve(team)
    deferred.promise

  @getByUser = (user_id) ->
    deferred = $q.defer()
    resource.by_user id: user_id, (teams) ->
      deferred.resolve(teams)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params,
      (team) ->
        deferred.resolve(team)
        $rootScope.$broadcast 'updated_teams'
      (resp) ->
        deferred.reject(resp)
    deferred.promise

  @delete = (deletedTeam) ->
    deferred = $q.defer()
    resource.delete id: deletedTeam.id, () ->
      deferred.resolve()
      $rootScope.$broadcast 'updated_teams'
    deferred.promise

  return
]
