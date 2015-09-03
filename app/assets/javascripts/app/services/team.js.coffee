@service.service 'Team',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  resource = $resource '/api/teams/:id', { id: '@id' },
    update: {
      method: 'PUT'
      url: '/api/teams/:id'
    }

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (teams) ->
      deferred.resolve(teams)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (team) ->
      deferred.resolve(team)
      $rootScope.$broadcast 'updated_teams'
    deferred.promise

  @get = (team_id) ->
    deferred = $q.defer()
    resource.get id: team_id, (team) ->
      deferred.resolve(team)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (team) ->
      deferred.resolve(team)
      $rootScope.$broadcast 'updated_teams'
    deferred.promise

  @delete = (deletedTeam) ->
    deferred = $q.defer()
    resource.delete id: deletedTeam.id, () ->
      deferred.resolve()
      $rootScope.$broadcast 'updated_teams'
    deferred.promise

  return
]
