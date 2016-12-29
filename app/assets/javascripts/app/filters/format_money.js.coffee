@filters.filter 'formatMoney', ->
    (input) ->
        input = Math.round(input)
        if input is 0
            return '$0'
        suffixes = ['','K', 'M', 'B', 'T', 'Q']
        exp = Math.floor(Math.log(Math.abs(input)) / Math.log(1000))
        result = Math.round(input / Math.pow(1000, exp) * 10) / 10

        if result >= 1000
            result = result / 1000
            exp += 1
        '$' + result + suffixes[exp]
