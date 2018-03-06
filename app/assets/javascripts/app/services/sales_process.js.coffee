@service.service 'SalesProcess',
['$resource', '$q'
($resource, $q) ->
  resource = $resource '/api/sales_processes', { id: '@id' },
    all:
      method: 'GET'
      url: '/api/sales_processes'
      isArray: true
    create:
      method: 'POST'
      url: '/api/sales_processes'
    update:
      method: 'PUT'
      url: '/api/sales_processes/:id'
    delete:
      method: 'DELETE'
      url: '/api/sales_processes/:id'

  @all = (params) -> resource.all(params).$promise
  @create = (params) -> resource.create(params).$promise
  @update = (params) -> resource.update(params).$promise
  @delete = (params) -> resource.delete(params).$promise

  return
]
