#= require support/spec_helper

describe 'Available Users Filter', ->
  describedFilter = undefined
  users = [
    { id: 1, team_id: null, 'leader?': false }
    { id: 2, team_id: 2, 'leader?': false  }
    { id: 3, team_id: 3, 'leader?': false }
    { id: 4, team_id: null, 'leader?': true  }
  ]


  beforeEach ->
    inject ($filter) ->
      describedFilter = $filter('availableUsers')

  it 'loads the filter', ->
    expect(describedFilter).toBeDefined()

  it 'returns an empty array if the user array is empty', ->
    expect(describedFilter([])).toEqual([])

  it 'returns only the users that have no team and are not a leader', ->
    expect(describedFilter(users)).toEqual([users[0]])
