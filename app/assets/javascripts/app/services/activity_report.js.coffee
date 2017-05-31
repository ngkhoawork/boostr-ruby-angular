@service.service 'ActivityReport',
['$resource', '$q',
($resource, $q) ->

  resource = $resource 'api/reports', {},
    by_account:
      method: 'GET'
      url: '/api/reports/summary_by_account'

  return resource
]
