@filters.filter 'boDate', ['$filter', ($filter) ->
  (month, short=false) ->
    if !month
      return ''
    date = new Date(month[0], month[1] - 1)
    if short
      $filter('date')(date, 'MMM yy')
    else
      $filter('date')(date, 'MMM yyyy')
]