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

  resource.user_types_list = [
    { name: 'Default', id: 0 }
    { name: 'Seller', id: 1 }
    { name: 'Sales Manager', id: 2 }
    { name: 'Account Manager', id: 3 }
    { name: 'Manager Account Manager', id: 4 }
    { name: 'Exec', id: 6 }
  ]

  resource.user_statuses_list = [
    { name: 'Active', value: true }
    { name: 'InActive', value: false }
  ]

  return resource
]
