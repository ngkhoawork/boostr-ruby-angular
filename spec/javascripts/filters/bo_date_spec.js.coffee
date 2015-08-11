#= require support/spec_helper

describe 'Custom Boostr Date Filter', ->
  describedFilter = undefined
  beforeEach ->
    inject ($filter) ->
      describedFilter = $filter('boDate')

  it 'loads the filter', ->
    expect(describedFilter).toBeDefined()

  it 'returns an empty string if the number is null', ->
    expect(describedFilter(null)).toBe ''

  it 'returns the a formatted date', ->
    expect(describedFilter([2015,9])).toBe 'Sep 2015'

  it 'returns the a formatted date', ->
    expect(describedFilter([2015,1])).toBe 'Jan 2015'

  it 'returns the a formatted date', ->
    expect(describedFilter([2015,12])).toBe 'Dec 2015'