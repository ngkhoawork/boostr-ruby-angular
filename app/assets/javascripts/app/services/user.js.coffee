@service.service 'User',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  resource = $resource '/api/users/:id', { id: '@id' },
    invite: {
      method: 'POST'
      url: '/api/users/invitation'
    }
    update: {
      method: 'PUT'
      url: '/api/users/:id'
    }

  resource.user_statuses_list = [
    { name: 'Active', value: true }
    { name: 'InActive', value: false }
  ]

  return resource
]
