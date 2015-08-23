@filters.filter 'availableUsers', ->
  (users) ->
    _.where(users, {team_id: null})
