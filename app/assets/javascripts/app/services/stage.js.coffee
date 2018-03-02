@service.service 'Stage',
['$resource', '$q'
($resource, $q) ->

  resource = $resource '/api/stages/:id', { id: '@id' },
    update:
      method: 'PUT'

  return resource
]
