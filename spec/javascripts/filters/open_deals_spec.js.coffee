#= require support/spec_helper

describe 'Open Deals Filter', ->
  describedFilter = undefined
  deals = [
    { id: 1, stage_id: 1 }
    { id: 2, stage_id: 2 }
    { id: 3, stage_id: 3 }
  ]

  stages = [
    { id: 1, open: true }
    { id: 2, open: true }
    { id: 3, open: false }
  ]

  beforeEach ->
    inject ($filter) ->
      describedFilter = $filter('openDeals')

  it 'loads the filter', ->
    expect(describedFilter).toBeDefined()

  it 'returns only the deals that are open', ->
    expect(describedFilter(deals, stages)).toEqual([{ id: 1, stage_id: 1}, { id: 2, stage_id: 2}])