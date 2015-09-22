#= require support/spec_helper

describe 'Available Users Filter', ->
  describedFilter = undefined
  users = [
    { id: 1, team_id: null }
    { id: 2, team_id: 2 }
    { id: 3, team_id: 3 }
    { id: 4, team_id: null }
  ]

  team = { id: 2, leader_id: 4 }

  beforeEach ->
    inject ($filter) ->
      describedFilter = $filter('availableUsers')

  it 'loads the filter', ->
    expect(describedFilter).toBeDefined()

  it 'returns an empty array if the number is null', ->
    expect(describedFilter([])).toEqual([])

  it 'returns only the users that have no team', ->
    expect(describedFilter(users)).toEqual([users[0], users[3]])

  it 'returns only the users that are not the leader of the team', ->
    expect(describedFilter(users, team)).toEqual([users[0]])
