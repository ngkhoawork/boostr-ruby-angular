@service.service 'Revenue',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/revenue/:id', { id: '@id' },
    get:
      method: 'GET'
      url: '/api/revenue'
      isArray: true
    forecast_detail:
      method: 'GET'
      url: 'api/revenue/forecast_detail'
      isArray: true
    spend_by_product:
      method: 'GET'
      url: 'api/revenue/report_by_category'
      isArray: true

  return resource
]
