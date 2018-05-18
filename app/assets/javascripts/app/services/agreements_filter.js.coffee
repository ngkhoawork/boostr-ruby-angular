@service.service 'AgreementsFilter', ->
    Selection = ->
        @name = ''
        @agreementType = ''
        @status = ''
        @client = ''
        @date =
            startDate: null
            endDate: null
        @target = ''    
        @track = ''    
        @isEmpty = true
        return

    selected = new Selection()

    return {
        selected: selected
        select: (key, value) ->
            this.selected[key] = value
            this.selected.isEmpty = false
        resetAll: ->
            newDataStore = new Selection()
            for key, val of newDataStore
                this.selected[key] = val
        reset: (key) ->
            this.selected[key] = new Selection()[key]
    }