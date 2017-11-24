@service.service 'PacingAlerts',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/dashboard/pacing_alerts'

  @get = (params) -> resource.get(params).$promise

  return
]
