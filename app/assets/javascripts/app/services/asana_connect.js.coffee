@service.service 'AsanaConnect',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  resource = $resource '/api/asana_connect/:id', { id: '@id' },
    update: {
      method: 'PUT'
      url: '/api/users/:id'
    }

  return resource
]
