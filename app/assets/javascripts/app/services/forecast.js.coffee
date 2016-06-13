@service.service 'Forecast',
['$resource', '$q',
($resource, $q) ->
  resource = $resource '/api/forecasts/:id', { id: '@id' }
  return resource
]
