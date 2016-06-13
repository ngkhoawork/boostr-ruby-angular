@filters.filter 'orderHashBy', ->
  (items, field, reverse) ->
    filtered = []
    angular.forEach items, (item, key) ->
      item.key = key
      filtered.push item

    filtered.sort (a, b) ->
      a[field] - b[field]

    filtered.reverse() if reverse
    filtered
