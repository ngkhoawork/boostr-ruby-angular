@filters.filter 'boDate', ['$filter', ($filter) ->
  (month) ->
    if !month
      return ''
    date = new Date(month[0], month[1] - 1)

    $filter('date')(date, 'MMM yyyy')
]