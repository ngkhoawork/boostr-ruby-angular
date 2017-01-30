@filters.filter 'convertCurrency', ->
  (input, rate) ->
    if rate
      parseInt(input * rate, 10) || 0
    else
      input
