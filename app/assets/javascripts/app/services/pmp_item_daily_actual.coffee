@service.service 'PMPItemDailyActual',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  transformRequest = (original, headers) ->
    original.pmp_item_daily_actual.values_attributes = original.pmp_item_daily_actual.values
    angular.toJson(original)

  resource = $resource '/api/pmps/:pmp_id/pmp_item_daily_actuals/:id', { pmp_id: '@pmp_id', id: '@id' },
    update: {
      method: 'PUT'
      url: '/api/pmps/:pmp_id/pmp_item_daily_actuals/:id'
      transformRequest: transformRequest
    }

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

  @delete = (params) ->
    deferred = $q.defer()
    resource.delete { pmp_id: params.pmp_id, id: params.id }, () ->
      deferred.resolve()
    deferred.promise

  return
]
