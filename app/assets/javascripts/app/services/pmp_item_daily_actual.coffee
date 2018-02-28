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
    aggregate: {
      method: 'GET'
      url: '/api/pmp_item_daily_actuals/aggregate'
      isArray: true
    }
    bulkAssignAdvertiser: {
      method: 'POST'
      url: 'api/pmp_item_daily_actuals/bulk_assign_advertiser'
      isArray: true
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

  @bulkAssignAdvertiser = (params) ->
    deferred = $q.defer()
    resource.bulkAssignAdvertiser params, (ids) ->
      deferred.resolve(ids)
    deferred.promise   

  @delete = (params) ->
    deferred = $q.defer()
    resource.delete { id: params.id }, () ->
      deferred.resolve()
    deferred.promise

  @aggregate = (params) ->
    deferred = $q.defer()
    resource.aggregate params, (pmp_item_daily_actuals) ->
      deferred.resolve(pmp_item_daily_actuals)
    deferred.promise

  return
]
