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

  run_forecast_calculation_resource = $resource '/api/forecasts/run_forecast_calculation'
  
  @run_forecast_calculation = () ->
    deferred = $q.defer()
    resource.run_forecast_calculation(
      (resp) ->
        deferred.resolve(resp)
      (error) ->
        deferred.reject(error)
    )
    deferred.promise
  return
]
