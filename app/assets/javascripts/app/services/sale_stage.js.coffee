@service.service 'SaleStage',
  ['$resource', ($resource) ->
    resource = $resource '/api/sales_stages', { id: '@id' },
      sale_stages:
        method: 'GET'
        url: '/api/sales_stages'
        isArray: true
      create:
        method: 'POST'
        url: '/api/sales_stages'
      update:
        method: 'PUT'
        url: '/api/sales_stages/:id'

    this.sale_stages = (params) -> resource.sale_stages(params).$promise
    this.create = (params) -> resource.create(params).$promise
    this.update = (params) -> resource.update(params).$promise
    return
  ]
