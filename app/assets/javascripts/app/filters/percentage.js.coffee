@filters.filter 'percentage', ['$filter', ($filter) ->
  (input, decimals) ->
    $filter('number')(input, if input == 0 then 0 else decimals) + '%';
]
