@service.service 'KPIDashboard',
['$resource',
($resource) ->

  resource = $resource '/api/kpis_dashboard', { },
    update: {
      method: 'PUT'
      url: '/api'
    }

  resource
]