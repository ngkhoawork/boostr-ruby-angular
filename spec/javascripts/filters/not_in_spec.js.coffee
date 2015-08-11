#= require support/spec_helper

describe 'Not In Filter', ->
  describedFilter = undefined
  beforeEach ->
    inject ($filter) ->
      describedFilter = $filter('notIn')

  input = [{ id: 1 }, { id: 2 }, { id: 3 }];
  other_array = [{ id: 2 }, { id: 3}];

  it 'loads the filter', ->
    expect(describedFilter).toBeDefined()

  it 'returns the whole array when the other array is empty', ->
    expect(describedFilter(input, [])).toEqual(input)

  it 'should not return an item from the other array', ->
    expect(describedFilter(input, other_array)).toEqual([{ id: 1 }])
