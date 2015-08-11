@service.service 'Deal',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  resource = $resource '/api/deals/:id', { id: '@id' }
  currentDeal = undefined
  allDeals = []

  @all = ->
    deferred = $q.defer()
    if allDeals.length == 0
      resource.query {}, (deals) =>
        allDeals = deals
        deferred.resolve(deals)
    else
      deferred.resolve(allDeals)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (deal) ->
      allDeals.push(deal)
      deferred.resolve(deal)
      $rootScope.$broadcast 'updated_deals'
    deferred.promise

  @get = (deal_id) ->
    deferred = $q.defer()
    resource.get id: deal_id, (deal) ->
      deferred.resolve(deal)
    deferred.promise

  @deal_types = () ->
    [
      'Test Campaign'
      'Sponsorship'
      'Seasonal'
      'Renewal'
    ]

  @source_types = () ->
    [
      'Pitch to Client'
      'Pitch to Agency'
      'RFP Response to Client'
      'RFP Response to Agency'
    ]

  return
]
