@service.service 'Team',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  resource = $resource '/api/teams/:id', { id: '@id' }

  @all = ->
    deferred = $q.defer()
    resource.query {}, (teams) ->
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

  return
]
