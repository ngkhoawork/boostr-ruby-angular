@service.service 'Company',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/company', {},
    update: {
      method: 'PUT'
      url: '/api/company'
    },
    save: {
      method: 'PUT'
      url: '/api/company'
    }

  return resource
]
