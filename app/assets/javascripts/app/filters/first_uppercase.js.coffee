@filters.filter 'firstUppercase', ->
    (str) ->
        if !!str then str.charAt(0).toUpperCase() + str.substr(1).toLowerCase() else ''