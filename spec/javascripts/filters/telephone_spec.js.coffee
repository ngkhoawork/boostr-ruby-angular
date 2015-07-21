#= require support/spec_helper

describe 'Telephone Number Filter', ->
  describedFilter = undefined
  beforeEach ->
    inject ($filter) ->
      describedFilter = $filter('tel')

  it 'loads the filter', ->
    expect(describedFilter).toBeDefined()

  it 'returns an empty string if the number is null', ->
    expect(describedFilter(null)).toBe ''

  it 'returns the a formatted US phone number', ->
    expect(describedFilter('2088675309')).toBe '(208) 867-5309'

