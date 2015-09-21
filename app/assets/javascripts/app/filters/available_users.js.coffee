@filters.filter 'availableUsers', ->
  (users, team={}) ->
    return users if users && users.length == 0
    users = _.where(users, {team_id: null})
    _.reject users, (user) ->
      user.id == team.leader_id