@filters.filter 'humanReadableMoney', ->
  (input) ->
    console.log('input', input)
    input = Math.round(input)
    if Math.abs(input) < 1000000
      if input < 0
        return "($" + Math.abs(input).toLocaleString() + ")"
      return "$" + input.toLocaleString()
    suffixes = ['K', 'M', 'B', 'T', 'Q']
    exp = Math.floor(Math.log(Math.abs(input)) / Math.log(1000))
    result = (Math.abs(input) / Math.pow(1000, exp)).toFixed(1)
    if result >= 1000
      result = result / 1000
      exp += 1
    if input < 0
      return "($" + result + suffixes[exp-1] + ")"
    "$" + result + suffixes[exp-1]

