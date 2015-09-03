@filters.filter 'notIn', ->
  (input, other_array, key = 'id') ->
    other_ids = _.pluck(other_array, key)
    _.reject input, (object) ->
      _.find other_ids, (other) ->
        other == object.id
