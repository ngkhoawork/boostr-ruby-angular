@service.service 'Validation',
['$resource', '$q'
($resource, $q) ->

  transformRequest = (original, headers) ->
    original.validation.criterion_attributes = original.validation.criterion
    angular.toJson(original)

  resource = $resource '/api/validations/:id', { id: '@id' },
    create:
      method: 'POST'
      transformRequest: transformRequest
      url: '/api/validations'
    update:
      method: 'PUT'
      transformRequest: transformRequest
    account_base_fields:
      method: 'GET'
      url: 'api/validations/account_base_fields'
    deal_base_fields:
      isArray: true
      method: 'GET'
      url: 'api/validations/deal_base_fields'

  return resource
]
