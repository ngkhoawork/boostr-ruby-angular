@service.service 'SSP',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  transformRequest = (original, headers) ->
    original.product.values_attributes = original.product.values
    angular.toJson(original)

  resource = $resource '/api/ssps/:id', { id: '@id', ssp_id: '@product_id' },

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (ssp) ->
      deferred.resolve(ssp)
    deferred.promise

  return
]
