@service.service 'SalesExecutionDashboard',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/sales_execution_dashboard/'

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (response) ->
      deferred.resolve(response)
    deferred.promise

  return
]