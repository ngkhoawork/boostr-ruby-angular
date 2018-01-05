@service.service 'PublisherDetails',
  ['$resource', ( $resource ) ->
    resource = $resource '/api/publisher_details', {id: '@id'},
    getPublisher:
      method: 'GET'
      url: '/api/publisher_details/:id'
    activities:
      method: 'GET'
      url: '/api/publisher_details/:id/activities'
    associations:
      method: 'GET'
      url: '/api/publisher_details/:id/associations'
    fill_rate_by_month_graph:
      method: 'GET'
      url: '/api/publisher_details/:id/fill_rate_by_month_graph'
      isArray: true
    daily_revenue_graph:
      method: 'GET'
      url: '/api/publisher_details/:id/daily_revenue_graph'
      isArray: true

    this.activities = (params) -> resource.activities(params).$promise
    this.getPublisher = (params) -> resource.getPublisher(params).$promise
    this.associations = (params) -> resource.associations(params).$promise
    this.fillRateByMonth = (params) -> resource.fill_rate_by_month_graph(params).$promise
    this.dailyRevenueGraph = (params) -> resource.daily_revenue_graph(params).$promise

    return
  ]