@service.service 'SalesExecutionDashboard',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/sales_execution_dashboard/'

  forecast_resource = $resource '/api/sales_execution_dashboard/forecast'

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (response) ->
      deferred.resolve(response)
    deferred.promise

  @forecast = (params) ->
    deferred = $q.defer()
    forecast_resource.query params, (response) ->
      deferred.resolve(response)
    deferred.promise

  return
]