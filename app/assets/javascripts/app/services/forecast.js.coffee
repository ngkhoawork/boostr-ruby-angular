@service.service 'Forecast',
['$resource', '$q',
($resource, $q) ->
  resource = $resource '/api/forecasts/:id', { id: '@id' },
    forecast_detail:
      method: 'GET'
      url: '/api/forecasts/detail'
    old_forecast_detail:
      method: 'GET'
      url: '/api/forecasts/old_detail'
    old_product_forecast_detail:
      method: 'GET'
      url: '/api/forecasts/old_product_detail'
      isArray: true
    product_forecast_detail:
      method: 'GET'
      url: '/api/forecasts/product_detail'
      isArray: true
    run_forecast_calculation:
      method: 'POST'
      url: '/api/forecasts/run_forecast_calculation'
    revenue_data:
      method: 'GET'
      url: '/api/forecasts/revenue_data'
      isArray: true
    pmp_data:
      method: 'GET'
      url: '/api/forecasts/pmp_data'
      isArray: true
    pmp_product_data:
      method: 'GET'
      url: '/api/forecasts/pmp_product_data'
      isArray: true
    pipeline_data:
      method: 'GET'
      url: '/api/forecasts/pipeline_data'
      isArray: true
  return resource
]
