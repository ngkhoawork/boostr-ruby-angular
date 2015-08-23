#= require support/spec_helper

describe 'Available Users Filter', ->
  describedFilter = undefined
  users = [
    { id: 1, team_id: null }
    { id: 2, team_id: 2 }
    { id: 3, team_id: 3 }
  ]

  beforeEach ->
    inject ($filter) ->
      describedFilter = $filter('availableUsers')

  it 'loads the filter', ->
    expect(describedFilter).toBeDefined()

  it 'returns an empty string if the number is null', ->
    expect(describedFilter([])).toBe ''

  it 'returns only the users that have no team', ->
    expect(describedFilter(users)).toEqual([{ id: 3, team_id: 3}, { id: 2, team_id: 2}])
