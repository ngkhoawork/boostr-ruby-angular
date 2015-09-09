@filters.filter 'notIn', ->
  (input, other_array) ->
    other_ids = _.pluck(other_array, 'id')
    _.reject input, (object) ->
      _.find other_ids, (other) ->
        other == object.id
