@filters.filter 'humanReadableMoney', ->
  (input) ->
    if input < 1000000
      return "$" + Math.ceil(input).toLocaleString()
    suffixes = ['M', 'B', 'T', 'Q']
    exp = Math.floor(Math.log(input) / Math.log(1000))
    result = (input / Math.pow(1000, exp)).toFixed(1)
    "$" + result + suffixes[exp-2]

