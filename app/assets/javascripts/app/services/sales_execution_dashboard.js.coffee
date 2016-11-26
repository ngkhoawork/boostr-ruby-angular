@service.service 'SalesExecutionDashboard',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/sales_execution_dashboard/'

  forecast_resource = $resource '/api/sales_execution_dashboard/forecast'

  monthly_forecast_resource = $resource '/api/sales_execution_dashboard/monthly_forecast'

  deal_loss_summary_resource = $resource '/api/sales_execution_dashboard/deal_loss_summary'

  deal_loss_stages_resource = $resource '/api/sales_execution_dashboard/deal_loss_stages'

  kpis_resource = $resource '/api/sales_execution_dashboard/kpis'

  activity_summary_resource = $resource '/api/sales_execution_dashboard/activity_summary'

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

  @monthly_forecast = (params) ->
    deferred = $q.defer()
    monthly_forecast_resource.get params, (response) ->
      deferred.resolve(response)
    deferred.promise

  @deal_loss_summary = (params) ->
    deferred = $q.defer()
    deal_loss_summary_resource.query params, (response) ->
      deferred.resolve(response)
    deferred.promise

  @kpis = (params) ->
    deferred = $q.defer()
    kpis_resource.query params, (response) ->
      deferred.resolve(response)
    deferred.promise

  @deal_loss_stages = (params) ->
    deferred = $q.defer()
    deal_loss_stages_resource.query params, (response) ->
      deferred.resolve(response)
    deferred.promise

  @activity_summary = (params) ->
    deferred = $q.defer()
    activity_summary_resource.query params, (response) ->
      deferred.resolve(response)
    deferred.promise

  return
]