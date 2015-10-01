@filters.filter 'availableUsers', ->
  (users) ->
    return users if users && users.length == 0
    _.where(users, {team_id: null, 'leader?': false})
