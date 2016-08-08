@service.service 'SalesExecutionDashboard',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/sales_execution_dashboard/'

  forecast_resource = $resource '/api/sales_execution_dashboard/forecast'

  deal_loss_summary_resource = $resource '/api/sales_execution_dashboard/deal_loss_summary'

  deal_loss_stages_resource = $resource '/api/sales_execution_dashboard/deal_loss_stages'

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

  @deal_loss_summary = (params) ->
    deferred = $q.defer()
    deal_loss_summary_resource.query params, (response) ->
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