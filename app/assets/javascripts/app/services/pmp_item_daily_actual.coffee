@service.service 'PMPItemDailyActual',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  transformRequest = (original, headers) ->
    original.pmp_item_daily_actual.values_attributes = original.pmp_item_daily_actual.values
    angular.toJson(original)

  resource = $resource '/api/pmp_item_daily_actuals/:id', { id: '@id' },
    update: {
      method: 'PUT'
      url: '/api/pmp_item_daily_actuals/:id'
      transformRequest: transformRequest
    }
    assignAdvertiser: {
      method: 'POST'
      url: '/api/pmp_item_daily_actuals/:id/assign_advertiser'
    }

  @query = resource.query

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (pmp_item_daily_actuals) ->
      deferred.resolve(pmp_item_daily_actuals)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (pmp_item_daily_actual) ->
      deferred.resolve(pmp_item_daily_actual)
    deferred.promise

  @assignAdvertiser = (params) ->
    deferred = $q.defer()
    resource.assignAdvertiser params, (pmp_item_daily_actual) ->
      deferred.resolve(pmp_item_daily_actual)
    deferred.promise    

  @delete = (params) ->
    deferred = $q.defer()
    resource.delete { id: params.id }, () ->
      deferred.resolve()
    deferred.promise

  return
]
