@service.service 'Deal',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  transformRequest = (original, headers) ->
    original.deal.values_attributes = original.deal.values
    angular.toJson(original)

  resource = $resource '/api/deals/:id', { id: '@id' },
    save: {
      method: 'POST'
      url: '/api/deals'
      transformRequest: transformRequest
    },
    update: {
      method: 'PUT'
      url: '/api/deals/:id'
      transformRequest: transformRequest
    }

  currentDeal = undefined

  @all = ->
    deferred = $q.defer()
    resource.query {}, (deals) ->
      deferred.resolve(deals)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (deal) ->
      deferred.resolve(deal)
      $rootScope.$broadcast 'updated_deals'
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (deal) ->
      deferred.resolve(deal)
      $rootScope.$broadcast 'updated_deals'
    deferred.promise

  @get = (deal_id) ->
    deferred = $q.defer()
    resource.get id: deal_id, (deal) ->
      deferred.resolve(deal)
    deferred.promise

  @allForClient = (client_id) ->
    deferred = $q.defer()
    resource.query { client_id: client_id}, (deals) ->
      deferred.resolve(deals)
    deferred.promise

  @delete = (deletedDeal) ->
    deferred = $q.defer()
    resource.delete id: deletedDeal.id, () ->
      deferred.resolve()
      $rootScope.$broadcast 'updated_deals'
    deferred.promise

  return
]
