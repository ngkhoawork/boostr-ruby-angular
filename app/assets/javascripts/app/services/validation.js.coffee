@service.service 'Validation',
['$resource', '$q'
($resource, $q) ->

  transformRequest = (original, headers) ->
    original.validation.criterion_attributes = original.validation.criterion
    angular.toJson(original)

  resource = $resource '/api/validations/:id', { id: '@id' },
    update:
      method: 'PUT'
      transformRequest: transformRequest
    account_base_fields:
      method: 'GET'
      url: 'api/validations/account_base_fields'

  return resource
]
