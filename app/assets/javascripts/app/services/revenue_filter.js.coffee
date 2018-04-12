@service.service 'RevenueFilter', ->
    Selection = ->
        @owner = ''
        @advertiser = ''
        @agency = ''
        @budget = ''
        @startDate =
            startDate: null
            endDate: null
        @endDate =
            startDate: null
            endDate: null
        @isEmpty = true
        @ioNumber = ''
        @externalIoNumber = ''
        return

    selected = new Selection()

    return {
        selected: selected
        select: (key, value) ->
            this.selected[key] = value
            this.selected.isEmpty = false
        resetAll: ->
            newSelection = new Selection()
            for key, val of newSelection
                this.selected[key] = val
        reset: (key) ->
            this.selected[key] = new Selection()[key]
    }