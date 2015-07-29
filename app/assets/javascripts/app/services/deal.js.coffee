@service.service 'Deal',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  resource = $resource '/api/deals/:id', { id: '@id' }

  allDeals = []

  @all = (callback) ->
    if allDeals.length == 0
      resource.query {}, (deals) =>
        allDeals = deals
        callback(deals)
    else
      callback(allDeals)

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (deal) ->
      allDeals.push(deal)
      deferred.resolve(deal)
      $rootScope.$broadcast 'updated_deals'
    deferred.promise


  @stages = () ->
    [
      'Prospect'
      'Needs Proposal'
      'In Negotiations'
      'Verbal Commitment'
      'Closed: Won'
      'Closed: Lost'
    ]

  return
]