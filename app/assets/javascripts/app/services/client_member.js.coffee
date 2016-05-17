@service.service 'ClientMember',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  transformRequest = (original, headers) ->
    original.values_attributes = original.values
    angular.toJson(original)

  resource = $resource '/api/clients/:client_id/client_members/:id', { client_id: '@client_id', id: '@id' },
    save: {
      method: 'POST'
      transformRequest: transformRequest
    },
    update: {
      method: 'PUT'
      transformRequest: transformRequest
    }

  return resource
]
