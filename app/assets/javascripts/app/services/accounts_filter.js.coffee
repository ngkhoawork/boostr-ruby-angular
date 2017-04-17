@service.service 'AccountsFilter', ->
  currentYear = moment().year()
  Selection = ->
    @owner = ''
    @category = ''
    @city = ''
    @type = ''
#    @exchange_rate = ''
    @date =
      startDate: null
      endDate: null
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