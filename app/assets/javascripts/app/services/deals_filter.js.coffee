@service.service 'DealsFilter', ->
    currentYear = moment().year()
    Selection = ->
        @owner = ''
        @advertiser = ''
        @agency = ''
        @budget = ''
        @exchange_rate = ''
        @yearClosed = currentYear
        @date =
            startDate: null
            endDate: null
        @isEmpty = true
        return

    selected = new Selection()

    return {
        currentYear: currentYear
        selected: selected
        select: (key, value) ->
            this.selected[key] = value
            this.selected.isEmpty = false
        resetAll: ->
            newSelection = new Selection()
            for key, val of newSelection
                this.selected[key] = val
        reset: (key) ->
            if key is 'yearClosed'
                this.selected[key] = ''
            else
                this.selected[key] = new Selection()[key]
    }