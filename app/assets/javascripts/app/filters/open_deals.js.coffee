@filters.filter 'openDeals', ->
  (deals, stages) ->
    openStages = _.where(stages, { open: true } )
    openStagesIds = _.pluck(openStages, 'id')

    _.filter deals, (deal) ->
      _.contains(openStagesIds, deal.stage_id)