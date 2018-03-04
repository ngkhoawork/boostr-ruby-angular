@service.service 'ContractsFilter', ->
    Selection = ->
        @field = ''
        @isEmpty = true
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