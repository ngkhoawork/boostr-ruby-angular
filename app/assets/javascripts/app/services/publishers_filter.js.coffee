@service.service 'PublishersFilter', ->
    Selection = ->
        @comscore = ''
        @stage = ''
        @type = ''
        @customFields = {}
        return

    selected = new Selection()

    return {
        selected: selected
        select: (key, value, isCustomField) ->
            if isCustomField
                this.selected.customFields[key] = value
            else
                this.selected[key] = value
        resetAll: ->
            newSelection = new Selection()
            for key, val of newSelection
                this.selected[key] = val
        reset: (key, isCustomField) ->
            if isCustomField
                this.selected.customFields[key] = new Selection().customFields[key]
            else
                this.selected[key] = new Selection()[key]
    }