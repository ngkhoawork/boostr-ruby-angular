@service.service 'Forecast',
['$resource', '$q',
($resource, $q) ->
  resource = $resource '/api/forecasts/:id', { id: '@id' },
    forecast_detail:
      method: 'GET'
      url: '/api/forecasts/detail'
    product_forecast_detail:
      method: 'GET'
      url: '/api/forecasts/product_detail'
      isArray: true
  return resource
]
