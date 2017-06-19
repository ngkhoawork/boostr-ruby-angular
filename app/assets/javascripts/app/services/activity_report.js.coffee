@service.service 'ActivityReport',
['$resource', '$q',
($resource, $q) ->

  resource = $resource 'api/reports', {}
  return resource
]
