@service.service 'Revenue',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/revenue/:id', { id: '@id' },
    get:
      method: 'GET'
      url: '/api/revenue'
      isArray: true

  return resource
]
