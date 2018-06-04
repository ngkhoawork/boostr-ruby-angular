@filters.filter 'percentage', ['$filter', ($filter) ->
  (input, decimals) ->
    if input?
      $filter('number')(input, if input == 0 then 0 else decimals) + '%';
]
