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

  @get = () ->
    currentDeal

  @set = (deal_id) =>
    currentDeal = _.find allDeals, (deal) ->
      return parseInt(deal_id) == deal.id
    $rootScope.$broadcast 'updated_current_deal'

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
