@filters.filter 'percentage', ['$filter', ($filter) ->
  (input, decimals) ->
    $filter('number')(input, decimals) + '%';
]
