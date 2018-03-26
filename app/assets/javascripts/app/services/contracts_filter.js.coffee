@service.service 'ContractsFilter', ->
    Selection = ->
        @type = null
        @status = null
        @advertiser = null
        @agency = null
        @deal = null
        @holdingCompany = null
        @member = null
        @startDate =
            startDate: null
            endDate: null
        @endDate =
            startDate: null
            endDate: null
        @isEmpty = true
        return

    selected = new Selection()

    return {
        selected: selected
        select: (key, value) ->
            this.selected[key] = value
            this.selected.isEmpty = false
        resetAll: ->
            _.extend this.selected, new Selection()
        reset: (key) ->
            this.selected[key] = new Selection()[key]
    }